import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// إشعارات المراجعة اليومية (أوفلاين)
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// جدولة تذكير يومي بالمراجعة (offline)
  Future<void> scheduleDailyReview({int hour = 8, int minute = 0}) async {
    const androidDetails = AndroidNotificationDetails(
      'review_channel',
      'مراجعة القرآن',
      channelDescription: 'تذكير يومي بمراجعة الآيات',
      importance: Importance.high,
      priority: Priority.high,
    );
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      1,
      '📖 مراجعة القرآن',
      'حان وقت مراجعتك اليومية لآياتك المستحقة',
      scheduled,
      const NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> showNow(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'review_channel',
      'مراجعة القرآن',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(2, title, body, const NotificationDetails(android: androidDetails));
  }
}
