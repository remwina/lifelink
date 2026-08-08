import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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
    final reminderAt = tz.TZDateTime.now(tz.local).add(
      const Duration(seconds: 10),
    );

    await _notifications.zonedSchedule(
      id: 1001,
      title: 'Donation day is coming! 💛',
      body: '$centerName · $date at $time',
      scheduledDate: reminderAt,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_reminders',
          'Appointment reminders',
          channelDescription: 'Reminders for upcoming blood donations',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
