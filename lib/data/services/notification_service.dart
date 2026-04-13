import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../core/constants/game_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _dailyReminderId = 0;
  static const _streakWarningId = 1;

  /// Initialize the notification plugin. Call once before runApp.
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Create the Android notification channel
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'learning_reminders',
        'Learning Reminders',
        description: 'Daily learning reminders and streak warnings',
        importance: Importance.high,
      ),
    );
  }

  /// Schedule a daily reminder at 20:00 local time, repeating every day.
  Future<void> scheduleDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);

    await _plugin.zonedSchedule(
      _dailyReminderId,
      '该学习啦！',
      '保持你的连续学习记录 \u{1F525}',
      _nextInstanceOf(20, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'learning_reminders',
          'Learning Reminders',
          channelDescription: 'Daily learning reminders and streak warnings',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a one-shot streak warning at [lastStudyDate] + 30 hours
  /// (6 hours before the 36-hour grace period expires).
  Future<void> scheduleStreakWarning(DateTime lastStudyDate) async {
    await _plugin.cancel(_streakWarningId);

    final warningTime = lastStudyDate.add(const Duration(hours: 30));
    final now = DateTime.now();

    // Don't schedule if the warning time is already in the past
    if (warningTime.isBefore(now)) return;

    final remainingHours =
        (GameConstants.streakGraceHours - 30).clamp(0, GameConstants.streakGraceHours);

    final scheduledTZ = tz.TZDateTime.from(warningTime, tz.local);

    await _plugin.zonedSchedule(
      _streakWarningId,
      '\u26A0\uFE0F 连击即将断裂！',
      '还有 $remainingHours 小时恢复时间，快来学习吧',
      scheduledTZ,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'learning_reminders',
          'Learning Reminders',
          channelDescription: 'Daily learning reminders and streak warnings',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Returns the next occurrence of [hour]:[minute] in local time.
  /// If today's time has passed, returns tomorrow's.
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
