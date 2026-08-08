import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/blood_supply.dart';
import '../models/booking.dart';
import '../models/donation_center.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/reminder_service.dart';

class AppProvider extends ChangeNotifier {
  final bool demoMode;
  late final FirestoreService _db;

  AppProvider({this.demoMode = false}) {
    if (!demoMode) _db = FirestoreService();
  }

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
          uid: uid,
          name: 'Donor',
          email: '',
          bloodType: '—',
        );
        notifyListeners();
      }
    });

    _userSub = _db
        .userProfileStream(uid)
        .listen(
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
              uid: uid,
              name: 'Donor',
              email: '',
              bloodType: '—',
            );
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
    _notifSub = _db
        .notificationsStream(uid)
        .listen(
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
    if (demoMode) {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
      return;
    }
    try {
      await _db.markAllNotificationsRead(uid);
    } catch (_) {}
  }

  Future<void> refreshNotifications(String uid) async {
    if (demoMode) return;
    final items = await _db.getNotifications(uid);
    _notifications = items;
    notifyListeners();
  }

  Future<void> markNotificationRead(String uid, String notificationId) async {
    if (demoMode) {
      _notifications = _notifications
          .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
          .toList();
      notifyListeners();
      return;
    }
    await _db.markNotificationRead(uid, notificationId);
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    if (demoMode) {
      _notifications = _notifications
          .where((n) => n.id != notificationId)
          .toList();
      notifyListeners();
      return;
    }
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
    _appointmentsSub = _db
        .appointmentsStream(uid)
        .listen(
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
    if (demoMode) {
      _loadDemoSession();
      return;
    }
    listenToUser(uid);
    listenToNotifications(uid);
    listenToCenters();
    listenToBloodSupply();
    listenToAppointments(uid);
    _seedIfNeeded();
  }

  void _loadDemoSession() {
    _user = UserProfile(
      uid: 'demo-donor',
      name: 'Jamie Donor',
      email: 'demo@lifelink.app',
      bloodType: 'O+',
      donationsTotal: 6,
      livesHelped: 18,
      bloodGivenL: 2.7,
      streakCount: 4,
      nextEligibleDate: 'Aug 22, 2026',
      challenges: const [
        Challenge(
          title: 'First Drop',
          description: 'Complete your first donation',
          current: 1,
          target: 1,
          reward: '🩸 First Drop Badge',
          completed: true,
        ),
        Challenge(
          title: 'Frequent Donor',
          description: 'Donate 5 times in a year',
          current: 4,
          target: 5,
          reward: '🏆 Gold Badge',
        ),
      ],
      badges: const [
        DonorBadge(emoji: '🩸', label: 'First Drop', earned: true),
        DonorBadge(emoji: '🔥', label: '4-Streak', earned: true),
        DonorBadge(emoji: '⭐', label: '10 Donations', earned: false),
        DonorBadge(emoji: '🏆', label: 'Life Saver', earned: false),
      ],
    );
    _bloodSupply = const [
      BloodSupplyEntry(type: 'A+', percentage: 72),
      BloodSupplyEntry(type: 'A−', percentage: 34),
      BloodSupplyEntry(type: 'B+', percentage: 58),
      BloodSupplyEntry(type: 'B−', percentage: 21),
      BloodSupplyEntry(type: 'AB+', percentage: 65),
      BloodSupplyEntry(type: 'AB−', percentage: 18),
      BloodSupplyEntry(type: 'O+', percentage: 47),
      BloodSupplyEntry(type: 'O−', percentage: 8),
    ];
    _centers = const [
      DonationCenter(
        id: 'demo-pgh',
        name: 'Philippine General Hospital',
        address: 'Taft Ave, Ermita',
        hours: 'Open until 8 PM',
        distanceKm: 1.2,
        slotStatus: SlotStatus.open,
        lat: 14.5794,
        lng: 120.9843,
      ),
      DonationCenter(
        id: 'demo-red-cross',
        name: 'Red Cross — Manila Chapter',
        address: 'Port Area',
        hours: 'Open until 5 PM',
        distanceKm: 5.1,
        slotStatus: SlotStatus.open,
        lat: 14.5995,
        lng: 120.9842,
      ),
    ];
    _notifications = const [
      NotificationItem(
        id: 'demo-urgent',
        type: NotificationType.urgent,
        title: 'O+ supply needs you',
        body: 'Your blood type is running low nearby. Every drop helps.',
        timeAgo: 'now',
        hasAction: true,
        actionLabel: 'Book Now',
      ),
      NotificationItem(
        id: 'demo-streak',
        type: NotificationType.achievement,
        title: 'You’re on a 4-donation streak!',
        body: 'Keep your kindness streak glowing.',
        timeAgo: '2h ago',
      ),
    ];
    notifyListeners();
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
      if (!demoMode) {
        await _db.createAppointment(appointment);
      } else {
        _appointments = [appointment];
      }
      try {
        await ReminderService.scheduleAppointmentReminder(
          centerName: appointment.centerName,
          date: appointment.date,
          time: appointment.time,
        );
      } on PlatformException catch (error) {
        debugPrint('AppProvider: reminder unavailable: $error');
      } on MissingPluginException catch (error) {
        debugPrint('AppProvider: reminder plugin unavailable: $error');
      }
      _bookingStep = 3;
    } catch (e) {
      _bookingError = 'Could not save appointment. Please try again.';
    } finally {
      _isConfirming = false;
      notifyListeners();
    }
  }
}
