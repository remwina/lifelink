import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/notification_item.dart';
import '../models/donation_center.dart';
import '../models/booking.dart';

class AppProvider extends ChangeNotifier {
  // ── Navigation ────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int i) {
    _currentIndex = i;
    notifyListeners();
  }

  // ── Pulse Alert overlay ───────────────────────────────────────────────────
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

  // ── User ──────────────────────────────────────────────────────────────────
  UserProfile get user => mockUser;

  // ── Notifications ─────────────────────────────────────────────────────────
  List<NotificationItem> _notifications = List.from(notificationsData);
  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAllRead() {
    _notifications = _notifications
        .map((n) => NotificationItem(
              id: n.id,
              type: n.type,
              title: n.title,
              body: n.body,
              timeAgo: n.timeAgo,
              isRead: true,
              hasAction: n.hasAction,
              actionLabel: n.actionLabel,
            ))
        .toList();
    notifyListeners();
  }

  // ── Centers ───────────────────────────────────────────────────────────────
  List<DonationCenter> get centers => centersData;

  // ── Booking flow ──────────────────────────────────────────────────────────
  int _bookingStep = 0; // 0=pick date/slot, 1=screener, 2=review, 3=confirmed
  int get bookingStep => _bookingStep;

  DonationCenter? _selectedCenter;
  DonationCenter? get selectedCenter => _selectedCenter;

  int _selectedDateIndex = 0;
  int get selectedDateIndex => _selectedDateIndex;

  TimeSlot? _selectedSlot;
  TimeSlot? get selectedSlot => _selectedSlot;

  Map<String, bool> _screenerAnswers = {};
  Map<String, bool> get screenerAnswers => _screenerAnswers;

  void selectCenter(DonationCenter c) {
    _selectedCenter = c;
    _bookingStep = 0;
    _selectedSlot = null;
    _screenerAnswers = {};
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
    _selectedSlot = null;
    _screenerAnswers = {};
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
}
