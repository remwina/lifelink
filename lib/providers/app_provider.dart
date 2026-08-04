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

  StreamSubscription<UserProfile?>? _userSub;

  void listenToUser(String uid) {
    _userSub?.cancel();
    _userSub = _db.userProfileStream(uid).listen((profile) async {
      if (profile == null) return;
      // Also load history (sub-collection, not in the stream)
      final history = await _db.getDonationHistory(uid);
      _user = profile.copyWith(history: history);
      notifyListeners();
    });
  }

  Future<void> refreshUserHistory(String uid) async {
    if (_user == null) return;
    final history = await _db.getDonationHistory(uid);
    _user = _user!.copyWith(history: history);
    notifyListeners();
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  StreamSubscription<List<NotificationItem>>? _notifSub;

  void listenToNotifications(String uid) {
    _notifSub?.cancel();
    _notifSub = _db.notificationsStream(uid).listen((items) {
      _notifications = items;
      notifyListeners();
    });
  }

  Future<void> markAllRead(String uid) async {
    await _db.markAllNotificationsRead(uid);
    // The stream will update _notifications automatically
  }

  // ── Donation centers ───────────────────────────────────────────────────────
  List<DonationCenter> _centers = [];
  List<DonationCenter> get centers => _centers;

  StreamSubscription<List<DonationCenter>>? _centersSub;

  void listenToCenters() {
    _centersSub?.cancel();
    _centersSub = _db.centersStream().listen((list) {
      _centers = list;
      notifyListeners();
    });
  }

  // ── Blood supply ───────────────────────────────────────────────────────────
  List<BloodSupplyEntry> _bloodSupply = [];
  List<BloodSupplyEntry> get bloodSupply => _bloodSupply;

  StreamSubscription<List<BloodSupplyEntry>>? _bloodSupplySub;

  void listenToBloodSupply() {
    _bloodSupplySub?.cancel();
    _bloodSupplySub = _db.bloodSupplyStream().listen((list) {
      _bloodSupply = list;
      notifyListeners();
    });
  }

  // ── Session management ─────────────────────────────────────────────────────

  /// Called once when a user signs in. Starts all real-time listeners.
  void startSession(String uid) {
    listenToUser(uid);
    listenToNotifications(uid);
    listenToCenters();
    listenToBloodSupply();
  }

  /// Called on sign-out. Cancels all listeners and clears state.
  void clearSession() {
    _userSub?.cancel();
    _notifSub?.cancel();
    _centersSub?.cancel();
    _bloodSupplySub?.cancel();
    _user = null;
    _notifications = [];
    _centers = [];
    _bloodSupply = [];
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

  /// Persists the appointment to Firestore, then advances to the confirmed step.
  Future<void> confirmBooking(String uid) async {
    if (_selectedCenter == null || _selectedSlot == null) return;
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
