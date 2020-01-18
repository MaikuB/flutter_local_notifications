import 'dart:async';

import 'package:flutter/services.dart';
import 'helpers.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import 'platform_specifics/android/initialization_settings.dart';
import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/ios/initialization_settings.dart';
import 'platform_specifics/ios/notification_details.dart';
import 'typedefs.dart';
import 'types.dart';

const MethodChannel _channel =
    MethodChannel('dexterous.com/flutter/local_notifications');

class MethodChannelFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  @override
  Future<void> cancel(int id) {
    validateId(id);
    return _channel.invokeMethod('cancel', id);
  }

  @override
  Future<void> cancelAll() {
    return _channel.invokeMethod('cancelAll');
  }

  @override
  Future<NotificationAppLaunchDetails> getNotificationAppLaunchDetails() async {
    final result =
        await _channel.invokeMethod('getNotificationAppLaunchDetails');
    return NotificationAppLaunchDetails(result['notificationLaunchedApp'],
        result.containsKey('payload') ? result['payload'] : null);
  }

  @override
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
}

class AndroidFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback _onSelectNotification;

  Future<bool> initialize(AndroidInitializationSettings initializationSettings,
      {SelectNotificationCallback onSelectNotification}) async {
    _onSelectNotification = onSelectNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  @override
  Future<void> show(int id, String title, String body,
      {AndroidNotificationDetails notificationDetails, String payload}) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'payload': payload ?? '',
        'platformSpecifics': notificationDetails?.toMap(),
      },
    );
  }

  /// Schedules a notification to be shown at the specified time with an optional payload that is passed through when a notification is tapped
  /// The [androidAllowWhileIdle] parameter is Android-specific and determines if the notification should still be shown at the specified time
  /// even when in a low-power idle mode.
  Future<void> schedule(int id, String title, String body,
      DateTime scheduledDate, AndroidNotificationDetails notificationDetails,
      {String payload, bool androidAllowWhileIdle = false}) async {
    validateId(id);
    var serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? Map<String, dynamic>();
    serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    await _channel.invokeMethod('schedule', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'millisecondsSinceEpoch': scheduledDate.millisecondsSinceEpoch,
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  @override
  Future<void> periodicallyShow(
      int id, String title, String body, RepeatInterval repeatInterval,
      {AndroidNotificationDetails notificationDetails, String payload}) async {
    validateId(id);
    await _channel.invokeMethod('periodicallyShow', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on a daily interval at the specified time
  Future<void> showDailyAtTime(int id, String title, String body,
      Time notificationTime, AndroidNotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);
    await _channel.invokeMethod('showDailyAtTime', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.Daily.index,
      'repeatTime': notificationTime.toMap(),
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on a daily interval at the specified time
  Future<void> showWeeklyAtDayAndTime(
      int id,
      String title,
      String body,
      Day day,
      Time notificationTime,
      AndroidNotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);

    await _channel.invokeMethod('showWeeklyAtDayAndTime', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.Weekly.index,
      'repeatTime': notificationTime.toMap(),
      'day': day.value,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'selectNotification':
        return _onSelectNotification(call.arguments);
      default:
        return Future.error('method not defined');
    }
  }
}

class IOSFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback _onSelectNotification;

  DidReceiveLocalNotificationCallback _onDidReceiveLocalNotificationCallback;

  Future<bool> initialize(IOSInitializationSettings initializationSettings,
      {SelectNotificationCallback onSelectNotification}) async {
    _onSelectNotification = onSelectNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  /// Schedules a notification to be shown at the specified time with an optional payload that is passed through when a notification is tapped
  Future<void> schedule(int id, String title, String body,
      DateTime scheduledDate, IOSNotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);
    await _channel.invokeMethod('schedule', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'millisecondsSinceEpoch': scheduledDate.millisecondsSinceEpoch,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  @override
  Future<void> show(int id, String title, String body,
      {IOSNotificationDetails notificationDetails, String payload}) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
        'payload': payload ?? '',
        'platformSpecifics': notificationDetails?.toMap(),
      },
    );
  }

  @override
  Future<void> periodicallyShow(
      int id, String title, String body, RepeatInterval repeatInterval,
      {IOSNotificationDetails notificationDetails, String payload}) async {
    validateId(id);
    await _channel.invokeMethod('periodicallyShow', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on a daily interval at the specified time
  Future<void> showDailyAtTime(int id, String title, String body,
      Time notificationTime, IOSNotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);
    await _channel.invokeMethod('showDailyAtTime', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.Daily.index,
      'repeatTime': notificationTime.toMap(),
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on a daily interval at the specified time
  Future<void> showWeeklyAtDayAndTime(
      int id,
      String title,
      String body,
      Day day,
      Time notificationTime,
      IOSNotificationDetails notificationDetails,
      {String payload}) async {
    validateId(id);

    await _channel.invokeMethod('showWeeklyAtDayAndTime', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.Weekly.index,
      'repeatTime': notificationTime.toMap(),
      'day': day.value,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'selectNotification':
        return _onSelectNotification(call.arguments);

      case 'didReceiveLocalNotification':
        return _onDidReceiveLocalNotificationCallback(
            call.arguments['id'],
            call.arguments['title'],
            call.arguments['body'],
            call.arguments['payload']);
      default:
        return Future.error('method not defined');
    }
  }
}
