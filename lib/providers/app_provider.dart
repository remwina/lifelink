import 'dart:async';
import 'package:flutter/material.dart';
import '../models/blood_supply.dart';
import '../models/booking.dart';
import '../models/donation_center.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
class AppProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  // ── Navigation ─────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int i) {
    _currentIndex = i;
    notifyListeners();
  }

  // ── Pulse Alert overlay ────────────────────────────────────────────────────
  bool _pulseAlertVisible = false;
  bool get pulseAlertVisible => _pulseAlertVisible;

  void showPulseAlert() {
    _pulseAlertVisible = true;
    notifyListeners();
  }

  void dismissPulseAlert() {
    _pulseAlertVisible = false;
    notifyListeners();
  }

  // ── User profile ───────────────────────────────────────────────────────────
  UserProfile? _user;
  UserProfile? get user => _user;

  bool _userLoading = false;
  bool get userLoading => _userLoading;

  StreamSubscription<UserProfile?>? _userSub;

  void listenToUser(String uid) {
    _userSub?.cancel();
    _userLoading = true;
    notifyListeners();

    // Hard timeout — if Firestore rules block the read, the stream
    // silently emits nothing (especially on web). After 6s we stop
    // spinning and show a fallback so the app is usable.
    Future.delayed(const Duration(seconds: 6), () {
      if (!_disposed && _userLoading) {
        debugPrint('AppProvider: userProfileStream timed out — using fallback');
        _userLoading = false;
        _user ??= UserProfile(
            uid: uid, name: 'Donor', email: '', bloodType: '—');
        notifyListeners();
      }
    });

    _userSub = _db.userProfileStream(uid).listen(
      (profile) async {
        if (profile == null) {
          // Document doesn't exist yet — wait for it
          return;
        }
        List<DonationHistory> history = [];
        try {
          history = await _db.getDonationHistory(uid);
        } catch (_) {}
        _user = profile.copyWith(history: history);
        _userLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('AppProvider: userProfileStream error: $error');
        _userLoading = false;
        _user ??= UserProfile(
            uid: uid, name: 'Donor', email: '', bloodType: '—');
        notifyListeners();
      },
    );
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _userSub?.cancel();
    _notifSub?.cancel();
    _centersSub?.cancel();
    _bloodSupplySub?.cancel();
    _appointmentsSub?.cancel();
    super.dispose();
  }

  Future<void> refreshUserHistory(String uid) async {
    if (_user == null) return;
    try {
      final history = await _db.getDonationHistory(uid);
      _user = _user!.copyWith(history: history);
      notifyListeners();
    } catch (_) {}
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  StreamSubscription<List<NotificationItem>>? _notifSub;

  void listenToNotifications(String uid) {
    _notifSub?.cancel();
    _notifSub = _db.notificationsStream(uid).listen(
      (items) {
        _notifications = items;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('AppProvider: notificationsStream error: $error');
      },
    );
  }

  Future<void> markAllRead(String uid) async {
    try {
      await _db.markAllNotificationsRead(uid);
    } catch (_) {}
  }

  Future<void> refreshNotifications(String uid) async {
    final items = await _db.getNotifications(uid);
    _notifications = items;
    notifyListeners();
  }

  Future<void> markNotificationRead(String uid, String notificationId) async {
    await _db.markNotificationRead(uid, notificationId);
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _db.deleteNotification(uid, notificationId);
  }

  // ── Donation centers ───────────────────────────────────────────────────────
  List<DonationCenter> _centers = [];
  List<DonationCenter> get centers => _centers;

  bool _centersLoading = false;
  bool get centersLoading => _centersLoading;

  StreamSubscription<List<DonationCenter>>? _centersSub;

  void listenToCenters() {
    _centersSub?.cancel();
    _centersLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 6), () {
      if (!_disposed && _centersLoading) {
        _centersLoading = false;
        notifyListeners();
      }
    });

    _centersSub = _db.centersStream().listen(
      (list) {
        _centers = list;
        _centersLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('AppProvider: centersStream error: $error');
        _centersLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Blood supply ───────────────────────────────────────────────────────────
  List<BloodSupplyEntry> _bloodSupply = [];
  List<BloodSupplyEntry> get bloodSupply => _bloodSupply;

  bool _bloodSupplyLoading = false;
  bool get bloodSupplyLoading => _bloodSupplyLoading;

  StreamSubscription<List<BloodSupplyEntry>>? _bloodSupplySub;

  void listenToBloodSupply() {
    _bloodSupplySub?.cancel();
    _bloodSupplyLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 6), () {
      if (!_disposed && _bloodSupplyLoading) {
        _bloodSupplyLoading = false;
        notifyListeners();
      }
    });

    _bloodSupplySub = _db.bloodSupplyStream().listen(
      (list) {
        _bloodSupply = list;
        _bloodSupplyLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('AppProvider: bloodSupplyStream error: $error');
        _bloodSupplyLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Appointments ──────────────────────────────────────────────────────────
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  Appointment? get nextAppointment {
    final upcoming = _appointments
        .where((a) => a.status == AppointmentStatus.upcoming)
        .toList();
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  StreamSubscription<List<Appointment>>? _appointmentsSub;

  void listenToAppointments(String uid) {
    _appointmentsSub?.cancel();
    _appointmentsSub = _db.appointmentsStream(uid).listen(
      (list) {
        _appointments = list;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('AppProvider: appointmentsStream error: $error');
      },
    );
  }

  // ── Session management ─────────────────────────────────────────────────────

  void startSession(String uid) {
    listenToUser(uid);
    listenToNotifications(uid);
    listenToCenters();
    listenToBloodSupply();
    listenToAppointments(uid);
    _seedIfNeeded();
  }

  Future<void> _seedIfNeeded() async {
    try {
      await Future.wait([
        _db.seedCentersIfEmpty(),
        _db.seedBloodSupplyIfEmpty(),
      ]);
    } catch (_) {
      // Seeding failed — streams will show empty state, retry next session
    }
  }

  void clearSession() {
    _userSub?.cancel();
    _notifSub?.cancel();
    _centersSub?.cancel();
    _bloodSupplySub?.cancel();
    _appointmentsSub?.cancel();
    _user = null;
    _userLoading = false;
    _notifications = [];
    _centers = [];
    _centersLoading = false;
    _bloodSupply = [];
    _bloodSupplyLoading = false;
    _appointments = [];
    _currentIndex = 0;
    _pulseAlertVisible = false;
    resetBooking();
    notifyListeners();
  }

  // ── Booking flow ───────────────────────────────────────────────────────────
  int _bookingStep = 0;
  int get bookingStep => _bookingStep;

  DonationCenter? _selectedCenter;
  DonationCenter? get selectedCenter => _selectedCenter;

  int _selectedDateIndex = 0;
  int get selectedDateIndex => _selectedDateIndex;

  TimeSlot? _selectedSlot;
  TimeSlot? get selectedSlot => _selectedSlot;

  Map<String, bool> _screenerAnswers = {};
  Map<String, bool> get screenerAnswers => _screenerAnswers;

  bool _isConfirming = false;
  bool get isConfirming => _isConfirming;

  String? _bookingError;
  String? get bookingError => _bookingError;

  void selectCenter(DonationCenter c) {
    _selectedCenter = c;
    _bookingStep = 0;
    _selectedSlot = null;
    _screenerAnswers = {};
    _bookingError = null;
    notifyListeners();
  }

  void selectDate(int index) {
    _selectedDateIndex = index;
    _selectedSlot = null;
    notifyListeners();
  }

  void selectSlot(TimeSlot slot) {
    if (!slot.available) return;
    _selectedSlot = slot;
    notifyListeners();
  }

  void advanceBooking() {
    if (_bookingStep < 3) {
      _bookingStep++;
      notifyListeners();
    }
  }

  void goBack() {
    if (_bookingStep > 0) {
      _bookingStep--;
      notifyListeners();
    }
  }

  void resetBooking() {
    _bookingStep = 0;
    _selectedCenter = null;
    _selectedDateIndex = 0;
    _selectedSlot = null;
    _screenerAnswers = {};
    _isConfirming = false;
    _bookingError = null;
    notifyListeners();
  }

  void setScreenerAnswer(String qId, bool answer) {
    _screenerAnswers[qId] = answer;
    notifyListeners();
  }

  bool get screenerComplete =>
      _screenerAnswers.length == screenerQuestions.length;

  bool get screenerPassed =>
      screenerComplete && _screenerAnswers.values.every((v) => v);

  // Fix #15: guard against empty uid
  Future<void> confirmBooking(String uid) async {
    if (uid.isEmpty) {
      _bookingError = 'You must be signed in to book an appointment.';
      notifyListeners();
      return;
    }
    if (_selectedCenter == null || _selectedSlot == null) {
      _bookingError = 'Please select a center, date and time.';
      notifyListeners();
      return;
    }

    _isConfirming = true;
    _bookingError = null;
    notifyListeners();

    try {
      final dates = bookingDates;
      final appointment = Appointment(
        id: '',
        userId: uid,
        centerName: _selectedCenter!.name,
        centerAddress: _selectedCenter!.address,
        centerId: _selectedCenter!.id,
        date: dates[_selectedDateIndex],
        time: _selectedSlot!.time,
      );
      await _db.createAppointment(appointment);
      _bookingStep = 3;
    } catch (e) {
      _bookingError = 'Could not save appointment. Please try again.';
    } finally {
      _isConfirming = false;
      notifyListeners();
    }
  }
}
