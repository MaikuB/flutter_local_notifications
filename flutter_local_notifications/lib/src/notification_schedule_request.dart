import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/src/schedule_accuracy.dart';
import 'package:flutter_local_notifications/src/schedule_type.dart';
import 'package:timezone/timezone.dart';

/// Specify the request params to schedule a notification.
class ScheduleNotificationRequest {
  ScheduleNotificationRequest({
    required this.scheduledDate,
    required this.uiLocalNotificationDateInterpretation,
    this.matchDateTimeComponents,
    this.androidScheduleType = ScheduleType.allowIdle,
    this.androidScheduleAccuracy = ScheduleAccuracy.regular,
  });

  final ScheduleType androidScheduleType;
  final ScheduleAccuracy androidScheduleAccuracy;
  final DateTimeComponents? matchDateTimeComponents;
  final TZDateTime scheduledDate;
  final UILocalNotificationDateInterpretation
      uiLocalNotificationDateInterpretation;
}
