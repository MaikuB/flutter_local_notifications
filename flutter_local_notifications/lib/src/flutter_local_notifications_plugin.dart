import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:platform/platform.dart';
import 'helpers.dart';
import 'initialization_settings.dart';
import 'notification_details.dart';
import 'pending_notification_request.dart';
import 'platform_flutter_local_notifications.dart';
import 'typedefs.dart';

/// The available intervals for periodically showing notifications
enum RepeatInterval { EveryMinute, Hourly, Daily, Weekly }

/// The days of the week
class Day {
  static const Sunday = Day(1);
  static const Monday = Day(2);
  static const Tuesday = Day(3);
  static const Wednesday = Day(4);
  static const Thursday = Day(5);
  static const Friday = Day(6);
  static const Saturday = Day(7);

  static get values =>
      [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday];

  final int value;

  const Day(this.value);
}

/// Used for specifying a time in 24 hour format
class Time {
  /// The hour component of the time. Accepted range is 0 to 23 inclusive
  final int hour;

  /// The minutes component of the time. Accepted range is 0 to 59 inclusive
  final int minute;

  /// The seconds component of the time. Accepted range is 0 to 59 inclusive
  final int second;

  Time([this.hour = 0, this.minute = 0, this.second = 0]) {
    assert(this.hour >= 0 && this.hour < 24);
    assert(this.minute >= 0 && this.minute < 60);
    assert(this.second >= 0 && this.second < 60);
  }

  Map<String, int> toMap() {
    return <String, int>{
      'hour': hour,
      'minute': minute,
      'second': second,
    };
  }
}

class FlutterLocalNotificationsPlugin {
  factory FlutterLocalNotificationsPlugin() => _instance;

  @visibleForTesting
  FlutterLocalNotificationsPlugin.private(
      MethodChannel channel, Platform platform)
      : _channel = channel,
        _platform = platform {
    if (platform.isAndroid) {
      FlutterLocalNotificationsPlatform.instance =
          AndroidFlutterLocalNotificationsPlugin();
    } else if (platform.isIOS) {
      FlutterLocalNotificationsPlatform.instance =
          IOSFlutterLocalNotificationsPlugin();
    }
  }

  static final FlutterLocalNotificationsPlugin _instance =
      FlutterLocalNotificationsPlugin.private(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          const LocalPlatform());

  final MethodChannel _channel;
  final Platform _platform;

  /// Initializes the plugin. Call this method on application before using the plugin further. This should only be done once. When a notification created by this plugin was used to launch the app, calling `initialize` is what will trigger to the `onSelectNotification` callback to be fire.
  Future<bool> initialize(InitializationSettings initializationSettings,
      {SelectNotificationCallback onSelectNotification}) async {
    if (_platform.isAndroid) {
      return await (FlutterLocalNotificationsPlatform.instance
              as AndroidFlutterLocalNotificationsPlugin)
          ?.initialize(initializationSettings?.android,
              onSelectNotification: onSelectNotification);
    } else if (_platform.isIOS) {
      return await (FlutterLocalNotificationsPlatform.instance
              as IOSFlutterLocalNotificationsPlugin)
          ?.initialize(initializationSettings?.ios,
              onSelectNotification: onSelectNotification);
    }
    throw Exception('Platform is not supported');
  }

  /// Returns info on if a notification had been used to launch the application.
  /// An example of how this could be used is to change the initial route of your application when it starts up.
  Future<NotificationAppLaunchDetails> getNotificationAppLaunchDetails() async {
    if (_platform.isAndroid) {
      return await (FlutterLocalNotificationsPlatform.instance
              as AndroidFlutterLocalNotificationsPlugin)
          ?.getNotificationAppLaunchDetails();
    } else if (_platform.isIOS) {
      return await (FlutterLocalNotificationsPlatform.instance
              as IOSFlutterLocalNotificationsPlugin)
          ?.getNotificationAppLaunchDetails();
    } else {
      throw Exception('Platform is not supported');
    }
  }

  /// Show a notification with an optional payload that will be passed back to the app when a notification is tapped
  Future<void> show(int id, String title, String body,
      NotificationDetails notificationDetails,
      {String payload}) async {
    if (_platform.isAndroid) {
      await (FlutterLocalNotificationsPlatform.instance
              as AndroidFlutterLocalNotificationsPlugin)
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.android,
              payload: payload);
    } else if (_platform.isIOS) {
      await (FlutterLocalNotificationsPlatform.instance
              as IOSFlutterLocalNotificationsPlugin)
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.iOS, payload: payload);
    } else {
      throw Exception('Platform is not supported');
    }
  }

  /// Cancel/remove the notification with the specified id. This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancel(int id) async {
    await FlutterLocalNotificationsPlatform.instance.cancel(id);
  }

  /// Cancels/removes all notifications. This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancelAll() async {
    await FlutterLocalNotificationsPlatform.instance.cancelAll();
  }

  /// Schedules a notification to be shown at the specified time with an optional payload that is passed through when a notification is tapped
  /// The [androidAllowWhileIdle] parameter is Android-specific and determines if the notification should still be shown at the specified time
  /// even when in a low-power idle mode.
  Future<void> schedule(int id, String title, String body,
      DateTime scheduledDate, NotificationDetails notificationDetails,
      {String payload, bool androidAllowWhileIdle = false}) async {
    validateId(id);
    var serializedPlatformSpecifics =
        _retrievePlatformSpecificNotificationDetails(notificationDetails);
    if (_platform.isAndroid) {
      serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    }
    await _channel.invokeMethod('schedule', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'millisecondsSinceEpoch': scheduledDate.millisecondsSinceEpoch,
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  /// Periodically show a notification using the specified interval.
  /// For example, specifying a hourly interval means the first time the notification will be an hour after the method has been called and then every hour after that.
  Future<void> periodicallyShow(int id, String title, String body,
      RepeatInterval repeatInterval, NotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);
    var serializedPlatformSpecifics =
        _retrievePlatformSpecificNotificationDetails(notificationDetails);
    await _channel.invokeMethod('periodicallyShow', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on a daily interval at the specified time
  Future<void> showDailyAtTime(int id, String title, String body,
      Time notificationTime, NotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);
    var serializedPlatformSpecifics =
        _retrievePlatformSpecificNotificationDetails(notificationDetails);
    await _channel.invokeMethod('showDailyAtTime', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.Daily.index,
      'repeatTime': notificationTime.toMap(),
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on a daily interval at the specified time
  Future<void> showWeeklyAtDayAndTime(int id, String title, String body,
      Day day, Time notificationTime, NotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);
    var serializedPlatformSpecifics =
        _retrievePlatformSpecificNotificationDetails(notificationDetails);
    await _channel.invokeMethod('showWeeklyAtDayAndTime', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.Weekly.index,
      'repeatTime': notificationTime.toMap(),
      'day': day.value,
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  /// Returns a list of notifications pending to be delivered/shown
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    final List<Map<dynamic, dynamic>> pendingNotifications =
        await _channel.invokeListMethod('pendingNotificationRequests');
    return pendingNotifications
        .map((pendingNotification) => PendingNotificationRequest(
            pendingNotification['id'],
            pendingNotification['title'],
            pendingNotification['body'],
            pendingNotification['payload']))
        .toList();
  }

  Map<String, dynamic> _retrievePlatformSpecificNotificationDetails(
      NotificationDetails notificationDetails) {
    Map<String, dynamic> serializedPlatformSpecifics;
    if (_platform.isAndroid) {
      serializedPlatformSpecifics = notificationDetails?.android?.toMap();
    } else if (_platform.isIOS) {
      serializedPlatformSpecifics = notificationDetails?.iOS?.toMap();
    }
    return serializedPlatformSpecifics;
  }
}
