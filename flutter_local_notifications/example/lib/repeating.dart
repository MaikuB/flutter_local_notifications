import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'padded_button.dart';
import 'plugin.dart';

List<Widget> examples(BuildContext context) => <Widget>[
      const Divider(),
      const Text(
        'Repeating notifications',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      PaddedElevatedButton(
        buttonText: 'Repeat notification every minute',
        onPressed: () async {
          await _repeatNotification();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Repeat notification every 5 minutes',
        onPressed: () async {
          await _repeatPeriodicallyWithDurationNotification();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Schedule daily 10:00:00 am notification in your '
            'local time zone',
        onPressed: () async {
          await _scheduleDailyTenAMNotification();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Schedule daily 10:00:00 am notification in your '
            "local time zone using last year's date",
        onPressed: () async {
          await _scheduleDailyTenAMLastYearNotification();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Schedule weekly 10:00:00 am notification in your '
            'local time zone',
        onPressed: () async {
          await _scheduleWeeklyTenAMNotification();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Schedule weekly Monday 10:00:00 am notification '
            'in your local time zone',
        onPressed: () async {
          await _scheduleWeeklyMondayTenAMNotification();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Schedule monthly Monday 10:00:00 am notification in '
            'your local time zone',
        onPressed: () async {
          await _scheduleMonthlyMondayTenAMNotification();
        },
      ),
      PaddedElevatedButton(
        buttonText: 'Schedule yearly Monday 10:00:00 am notification in '
            'your local time zone',
        onPressed: () async {
          await _scheduleYearlyMondayTenAMNotification();
        },
      ),
    ];

/// To test we don't validate past dates when using `matchDateTimeComponents`
Future<void> _scheduleDailyTenAMLastYearNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'daily scheduled notification title',
      'daily scheduled notification body',
      _nextInstanceOfTenAMLastYear(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily notification channel id', 'daily notification channel name',
            channelDescription: 'daily notification description'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time);
}

Future<void> _scheduleWeeklyTenAMNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'weekly scheduled notification title',
      'weekly scheduled notification body',
      _nextInstanceOfTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails('weekly notification channel id',
            'weekly notification channel name',
            channelDescription: 'weekly notificationdescription'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
}

Future<void> _scheduleWeeklyMondayTenAMNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'weekly scheduled notification title',
      'weekly scheduled notification body',
      _nextInstanceOfMondayTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails('weekly notification channel id',
            'weekly notification channel name',
            channelDescription: 'weekly notificationdescription'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
}

Future<void> _scheduleMonthlyMondayTenAMNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'monthly scheduled notification title',
      'monthly scheduled notification body',
      _nextInstanceOfMondayTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails('monthly notification channel id',
            'monthly notification channel name',
            channelDescription: 'monthly notificationdescription'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime);
}

Future<void> _scheduleYearlyMondayTenAMNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'yearly scheduled notification title',
      'yearly scheduled notification body',
      _nextInstanceOfMondayTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails('yearly notification channel id',
            'yearly notification channel name',
            channelDescription: 'yearly notification description'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime);
}

Future<void> _repeatNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          'repeating channel id', 'repeating channel name',
          channelDescription: 'repeating description');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.periodicallyShow(
    id++,
    'repeating title',
    'repeating body',
    RepeatInterval.everyMinute,
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> _repeatPeriodicallyWithDurationNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          'repeating channel id', 'repeating channel name',
          channelDescription: 'repeating description');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.periodicallyShowWithDuration(
    id++,
    'repeating period title',
    'repeating period body',
    const Duration(minutes: 5),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> _scheduleDailyTenAMNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'daily scheduled notification title',
      'daily scheduled notification body',
      _nextInstanceOfTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily notification channel id', 'daily notification channel name',
            channelDescription: 'daily notification description'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time);
}

tz.TZDateTime _nextInstanceOfTenAM() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

tz.TZDateTime _nextInstanceOfTenAMLastYear() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  return tz.TZDateTime(tz.local, now.year - 1, now.month, now.day, 10);
}

tz.TZDateTime _nextInstanceOfMondayTenAM() {
  tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
  while (scheduledDate.weekday != DateTime.monday) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}
