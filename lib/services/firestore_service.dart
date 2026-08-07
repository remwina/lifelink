import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_supply.dart';
import '../models/booking.dart';
import '../models/donation_center.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';

/// Central data-access layer for Firestore.
///
/// Firestore schema:
///   users/{uid}
///     ├── (fields: name, email, bloodType, donationsTotal, …)
///     └── donationHistory/{docId}   — sub-collection
///
///   appointments/{docId}            — global collection filtered by userId
///
///   notifications/{uid}/items/{docId}  — per-user sub-collection
///
///   centers/{docId}                 — donation centers (admin-managed)
///
///   bloodSupply/{type}              — blood supply levels (admin-managed)
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection refs (also exposed for admin screen) ───────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get centersCollection =>
      _db.collection('centers');

  CollectionReference<Map<String, dynamic>> get bloodSupplyCollection =>
      _db.collection('bloodSupply');

  CollectionReference<Map<String, dynamic>> get _centers => centersCollection;

  CollectionReference<Map<String, dynamic>> get _bloodSupply =>
      bloodSupplyCollection;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('appointments');

  CollectionReference<Map<String, dynamic>> _notificationsFor(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  CollectionReference<Map<String, dynamic>> _historyFor(String uid) =>
      _users.doc(uid).collection('donationHistory');

  // ── User profile ───────────────────────────────────────────────────────────

  /// Creates the Firestore document for a brand-new user and seeds their data.
  Future<void> createUserProfile(UserProfile profile) async {
    final batch = _db.batch();

    // Main user document
    batch.set(_users.doc(profile.uid), {
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Seed notifications
    for (final n in seedNotifications) {
      batch.set(_notificationsFor(profile.uid).doc(), n);
    }

    await batch.commit();
  }

  /// Fetches a user profile + donation history in a single call.
  Future<UserProfile?> getUserProfile(String uid) async {
    final docSnap = await _users.doc(uid).get();
    if (!docSnap.exists) return null;

    final profile = UserProfile.fromFirestore(docSnap);
    final history = await getDonationHistory(uid);
    return profile.copyWith(history: history);
  }

  /// Real-time stream of the user document (without history sub-collection).
  Stream<UserProfile?> userProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromFirestore(snap);
    });
  }

  /// Updates only the specified fields on the user document.
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Donation history ───────────────────────────────────────────────────────

  Future<List<DonationHistory>> getDonationHistory(String uid) async {
    // Order by the server timestamp field, falling back gracefully
    final snap = await _historyFor(uid)
        .orderBy('donatedAt', descending: true)
        .limit(20)
        .get();
    return snap.docs.map(DonationHistory.fromFirestore).toList();
  }

  Future<void> addDonationHistory(
      String uid, DonationHistory entry) async {
    await _historyFor(uid).add(entry.toFirestore());
  }

  // ── Appointments ───────────────────────────────────────────────────────────

  /// Saves a new appointment and returns its Firestore id.
  Future<String> createAppointment(Appointment appointment) async {
    final ref = await _appointments.add(appointment.toFirestore());
    return ref.id;
  }

  /// Real-time stream of upcoming appointments for a user.
  Stream<List<Appointment>> appointmentsStream(String uid) {
    return _appointments
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(Appointment.fromFirestore).toList());
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  Stream<List<NotificationItem>> notificationsStream(String uid) {
    return _notificationsFor(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(NotificationItem.fromFirestore).toList());
  }

  Future<List<NotificationItem>> getNotifications(String uid) async {
    final snap = await _notificationsFor(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(NotificationItem.fromFirestore).toList();
  }

  Future<void> markNotificationRead(String uid, String notificationId) async {
    await _notificationsFor(uid).doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _notificationsFor(uid).doc(notificationId).delete();
  }

  Future<void> markAllNotificationsRead(String uid) async {
    final snap =
        await _notificationsFor(uid).where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Donation centers ───────────────────────────────────────────────────────

  /// One-time fetch of all donation centers.
  Future<List<DonationCenter>> getCenters() async {
    final snap = await _centers.orderBy('distanceKm').get();
    return snap.docs.map(DonationCenter.fromFirestore).toList();
  }

  /// Real-time stream of donation centers.
  Stream<List<DonationCenter>> centersStream() {
    return _centers.orderBy('distanceKm').snapshots().map(
        (snap) => snap.docs.map(DonationCenter.fromFirestore).toList());
  }

  // ── Blood supply ───────────────────────────────────────────────────────────

  /// Real-time stream of blood supply levels.
  Stream<List<BloodSupplyEntry>> bloodSupplyStream() {
    return _bloodSupply.snapshots().map(
        (snap) => snap.docs.map(BloodSupplyEntry.fromFirestore).toList());
  }

  // ── One-time seeding ───────────────────────────────────────────────────────

  /// Writes centers to Firestore if the collection is empty.
  /// Safe to call on every app start — only seeds once.
  Future<void> seedCentersIfEmpty() async {
    final snap = await _centers.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final c in seedCenters) {
      batch.set(_centers.doc(), c);
    }
    await batch.commit();
  }

  /// Writes blood supply levels to Firestore if the collection is empty.
  Future<void> seedBloodSupplyIfEmpty() async {
    final snap = await _bloodSupply.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final entry in seedBloodSupply) {
      // Use the blood type as document id so admins can find it easily
      batch.set(_bloodSupply.doc(entry['type'] as String), entry);
    }
    await batch.commit();
  }
}
