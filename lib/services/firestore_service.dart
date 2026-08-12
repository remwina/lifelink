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

  /// Updates an appointment's status to cancelled.
  Future<void> cancelAppointment(String appointmentId) async {
    await _appointments.doc(appointmentId).update({
      'status': AppointmentStatus.cancelled.name,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks an appointment as completed and atomically updates the donor's
  /// stats: donationsTotal++, livesHelped += 3, bloodGivenL += 0.45,
  /// streakCount++, nextEligibleDate (56 days from now), and adds a
  /// donationHistory entry.
  Future<void> completeAppointment(Appointment appointment) async {
    const double volumeL = 0.45;
    const int livesPerDonation = 3;
    const int eligibilityDays = 56;

    final now = DateTime.now();
    final eligible = now.add(const Duration(days: eligibilityDays));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final eligibleStr =
        '${months[eligible.month - 1]} ${eligible.day}, ${eligible.year}';

    final batch = _db.batch();

    // 1. Update appointment status
    batch.update(_appointments.doc(appointment.id), {
      'status': AppointmentStatus.completed.name,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // 2. Increment donor stats atomically
    batch.update(_users.doc(appointment.userId), {
      'donationsTotal': FieldValue.increment(1),
      'livesHelped': FieldValue.increment(livesPerDonation),
      'bloodGivenL': FieldValue.increment(volumeL),
      'streakCount': FieldValue.increment(1),
      'nextEligibleDate': eligibleStr,
      'daysUntilEligible': eligibilityDays,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3. Add a donation history entry
    final historyRef = _historyFor(appointment.userId).doc();
    batch.set(historyRef, {
      'center': appointment.centerName,
      'type': 'Whole Blood',
      'volumeL': volumeL,
      'date': appointment.date,
      'donatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // 4. Recalculate challenges and badges after commit
    await _updateChallengesAndBadges(appointment.userId);
  }

  /// Recalculates challenge progress and badge earned status based on
  /// current user stats (donationsTotal, livesHelped, streakCount).
  Future<void> _updateChallengesAndBadges(String uid) async {
    final userDoc = await _users.doc(uid).get();
    if (!userDoc.exists) return;

    final data = userDoc.data()!;
    final donationsTotal = (data['donationsTotal'] as num?)?.toInt() ?? 0;
    final livesHelped = (data['livesHelped'] as num?)?.toInt() ?? 0;
    final streakCount = (data['streakCount'] as num?)?.toInt() ?? 0;

    // Update challenges
    final challenges = [
      {
        'title': 'First Drop',
        'description': 'Complete your first donation',
        'current': donationsTotal.clamp(0, 1),
        'target': 1,
        'reward': '🩸 First Drop Badge',
        'completed': donationsTotal >= 1,
      },
      {
        'title': 'Frequent Donor',
        'description': 'Donate 5 times in a year',
        'current': donationsTotal.clamp(0, 5),
        'target': 5,
        'reward': '🏆 Gold Badge',
        'completed': donationsTotal >= 5,
      },
      {
        'title': 'Community Hero',
        'description': 'Help 50 lives through donations',
        'current': livesHelped.clamp(0, 50),
        'target': 50,
        'reward': '🌟 Hero Badge',
        'completed': livesHelped >= 50,
      },
    ];

    // Update badges
    final badges = [
      {
        'emoji': '🩸',
        'label': 'First Drop',
        'earned': donationsTotal >= 1,
      },
      {
        'emoji': '🔥',
        'label': '4-Streak',
        'earned': streakCount >= 4,
      },
      {
        'emoji': '⭐',
        'label': '10 Donations',
        'earned': donationsTotal >= 10,
      },
      {
        'emoji': '🏆',
        'label': 'Life Saver',
        'earned': livesHelped >= 15,
      },
      {
        'emoji': '🌟',
        'label': 'Hero',
        'earned': livesHelped >= 50,
      },
      {
        'emoji': '💎',
        'label': 'Elite',
        'earned': donationsTotal >= 25,
      },
    ];

    await _users.doc(uid).update({
      'challenges': challenges,
      'badges': badges,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  // ── Admin analytics ─────────────────────────────────────────────────────────

  /// One-time fetch of all user documents.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllUsers() async {
    final snap = await _users.get();
    return snap.docs;
  }

  /// One-time fetch of all appointment documents.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllAppointments() async {
    final snap = await _appointments.get();
    return snap.docs;
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
