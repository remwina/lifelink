import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      windows: WindowsInitializationSettings(
        appName: 'LifeLink',
        appUserModelId: 'com.lifelink.app',
        guid: '7d4cb0f1-7e52-4c5d-ae3c-3f6bb6f4c6e1',
      ),
    );
    await _notifications.initialize(settings: settings);
  }

  static Future<void> scheduleAppointmentReminder({
    required String centerName,
    required String date,
    required String time,
  }) async {
    if (kIsWeb) return;

    // TODO: Fix API compatibility with flutter_local_notifications v22.3.0
    // The zonedSchedule API has changed and needs to be updated
    debugPrint('Reminder scheduling disabled - API update needed');
    debugPrint('Would schedule reminder for: $centerName on $date at $time');
    
    /* 
    try {
      final dateTime = _parseAppointmentDateTime(date, time);
      if (dateTime == null) {
        debugPrint('Failed to parse appointment date/time: $date $time');
        return;
      }

      final reminderAt = tz.TZDateTime.from(
        dateTime.subtract(const Duration(hours: 24)),
        tz.local,
      );

      if (reminderAt.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('Reminder time is in the past, skipping: $reminderAt');
        return;
      }

      final notificationId =
          Object.hash(centerName, date, time).abs() % 2147483647;

      // API needs update for v22.3.0
      await _notifications.zonedSchedule(...);

      debugPrint('Scheduled reminder for $reminderAt');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
    */
  }

  /// Parses appointment date and time strings into a DateTime.
  /// Date format: "Jan 15, 2026" or "Aug 22, 2026"
  /// Time format: "09:00 AM" or "2:30 PM"
  static DateTime? _parseAppointmentDateTime(String date, String time) {
    try {
      // Parse date: "Jan 15, 2026"
      final dateParts = date.split(RegExp(r'[,\s]+'));
      if (dateParts.length < 3) return null;

      final monthStr = dateParts[0];
      final day = int.tryParse(dateParts[1]);
      final year = int.tryParse(dateParts[2]);

      if (day == null || year == null) return null;

      const months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final month = months[monthStr];
      if (month == null) return null;

      // Parse time: "09:00 AM" or "2:30 PM"
      final timeParts = time.split(' ');
      if (timeParts.length != 2) return null;

      final hourMinute = timeParts[0].split(':');
      if (hourMinute.length != 2) return null;

      var hour = int.tryParse(hourMinute[0]);
      final minute = int.tryParse(hourMinute[1]);

      if (hour == null || minute == null) return null;

      final isPM = timeParts[1].toUpperCase() == 'PM';
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      debugPrint('Error parsing date/time: $e');
      return null;
    }
  }

  /// Cancels a scheduled reminder for a specific appointment.
  static Future<void> cancelAppointmentReminder({
    required String centerName,
    required String date,
    required String time,
  }) async {
    if (kIsWeb) return;
    
    // TODO: Fix API compatibility with flutter_local_notifications v22.3.0
    debugPrint('Reminder cancellation disabled - API update needed');
    debugPrint('Would cancel reminder for: $centerName on $date');
    
    /*
    try {
      final notificationId =
          Object.hash(centerName, date, time).abs() % 2147483647;
      await _notifications.cancel(...);
      debugPrint('Cancelled reminder for appointment: $centerName on $date');
    } catch (e) {
      debugPrint('Error cancelling reminder: $e');
    }
    */
  }
}
