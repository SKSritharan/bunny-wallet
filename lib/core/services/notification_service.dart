import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:bunny_wallet/data/models/credit_card_model.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> schedulePaymentReminder(
      CreditCardModel card, int daysBefore) async {
    await init();

    final now = DateTime.now();
    var dueDate = DateTime(now.year, now.month, card.dueDay);

    if (dueDate.isBefore(now)) {
      dueDate = DateTime(now.year, now.month + 1, card.dueDay);
    }

    final reminderDate =
        dueDate.subtract(Duration(days: daysBefore));

    if (reminderDate.isBefore(now)) {
      final nextMonth = DateTime(now.year, now.month + 1, card.dueDay);
      final nextReminderDate =
          nextMonth.subtract(Duration(days: daysBefore));
      await _scheduleNotification(
        id: card.id.hashCode + daysBefore,
        title: 'Payment Due Soon',
        body:
            '${card.name} (*${card.lastFourDigits}) payment is due in $daysBefore ${daysBefore == 1 ? "day" : "days"}',
        scheduledDate: nextReminderDate,
      );
    } else {
      await _scheduleNotification(
        id: card.id.hashCode + daysBefore,
        title: 'Payment Due Soon',
        body:
            '${card.name} (*${card.lastFourDigits}) payment is due in $daysBefore ${daysBefore == 1 ? "day" : "days"}',
        scheduledDate: reminderDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'payment_reminders',
      'Payment Reminders',
      channelDescription: 'Reminders for credit card payments',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showNow({
    required String title,
    required String body,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'general',
      'General',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}
