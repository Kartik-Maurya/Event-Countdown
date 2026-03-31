import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/event.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {}

  static Future<void> scheduleEventReminder(Event event) async {
    if (kIsWeb || !event.reminderEnabled) return;
    await initialize();

    final reminderTime =
        event.dateTime.subtract(Duration(minutes: event.reminderMinutesBefore));

    if (reminderTime.isBefore(DateTime.now())) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int id = event.id.hashCode & 0x7FFFFFFF;
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      'Upcoming: ${event.title}',
      _getReminderBody(event),
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      payload: event.id,
    );
  }

  static String _getReminderBody(Event event) {
    final remaining = event.dateTime.difference(DateTime.now());
    if (remaining.inDays > 0) {
      return 'In ${remaining.inDays} day${remaining.inDays > 1 ? 's' : ''} - ${event.category.label}';
    } else if (remaining.inHours > 0) {
      return 'In ${remaining.inHours} hour${remaining.inHours > 1 ? 's' : ''} - ${event.category.label}';
    } else {
      return 'In ${remaining.inMinutes} minute${remaining.inMinutes > 1 ? 's' : ''} - ${event.category.label}';
    }
  }

  static Future<void> cancelReminder(String eventId) async {
    if (kIsWeb) return;
    await initialize();
    await _notificationsPlugin.cancel(eventId.hashCode & 0x7FFFFFFF);
  }

  static Future<void> cancelAllReminders() async {
    if (kIsWeb) return;
    await initialize();
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> showInstantNotification(String title, String body) async {
    if (kIsWeb) return;
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }
}
