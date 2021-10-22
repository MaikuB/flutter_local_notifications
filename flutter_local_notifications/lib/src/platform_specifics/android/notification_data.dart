import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

/// Contains notification data specific to Android.
class NotificationData{

  /// Constructs an instance of [NotificationData].
  NotificationData(this.id, this.title, this.body,
      this.scheduledDate, this.notificationDetails,
      {this.androidAllowWhileIdle, this.payload, this.matchDateTimeComponents});

  /// The notificatin's id.
  final int id;

  /// The notificatin's title.
  final String? title;

  /// The notificatin's body text.
  final String? body;

  /// The notificatin's scheduled date time.
  final TZDateTime scheduledDate;

  /// The notificatin's details.
  final NotificationDetails notificationDetails;

  /// On Android, the `androidAllowWhileIdle` is used to determine if
  ///the notification should be delivered at the specified time even when
  ///the device in a low-power idle mode.
  final bool? androidAllowWhileIdle;

  /// The notificatin's payload.
  final String? payload;

  ///There is an optional `matchDateTimeComponents` parameter that can be used
  ///to schedule a notification to appear on a daily or weekly basis by telling
  ///the plugin to match on the time or a combination of day of the week
  ///and time respectively.
  final DateTimeComponents? matchDateTimeComponents;






}