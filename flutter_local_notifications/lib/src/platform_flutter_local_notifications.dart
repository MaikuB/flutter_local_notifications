import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/timezone.dart';

import 'helpers.dart';
import 'platform_specifics/android/active_notification.dart';
import 'platform_specifics/android/initialization_settings.dart';
import 'platform_specifics/android/method_channel_mappers.dart';
import 'platform_specifics/android/notification_channel.dart';
import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/ios/enums.dart';
import 'platform_specifics/ios/initialization_settings.dart';
import 'platform_specifics/ios/method_channel_mappers.dart';
import 'platform_specifics/ios/notification_details.dart';
import 'platform_specifics/macos/initialization_settings.dart';
import 'platform_specifics/macos/method_channel_mappers.dart';
import 'platform_specifics/macos/notification_details.dart';
import 'type_mappers.dart';
import 'typedefs.dart';
import 'types.dart';
import 'tz_datetime_mapper.dart';

const MethodChannel _channel =
    MethodChannel('dexterous.com/flutter/local_notifications');

/// An implementation of a local notifications platform using method channels.
class MethodChannelFlutterLocalNotificationsPlugin
    extends FlutterLocalNotificationsPlatform {
  @override
  Future<void> cancel(int id) {
    validateId(id);
    return _channel.invokeMethod('cancel', id);
  }

  @override
  Future<void> cancelAll() => _channel.invokeMethod('cancelAll');

  @override
  Future<NotificationAppLaunchDetails> getNotificationAppLaunchDetails() async {
    final Map<Object, Object> result =
        await _channel.invokeMethod('getNotificationAppLaunchDetails');
    return result != null
        ? NotificationAppLaunchDetails(result['notificationLaunchedApp'],
            result.containsKey('payload') ? result['payload'] : null)
        : null;
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    final List<Map<Object, Object>> pendingNotifications =
        await _channel.invokeListMethod('pendingNotificationRequests');
    return pendingNotifications
        // ignore: always_specify_types
        .map((p) => PendingNotificationRequest(
            p['id'], p['title'], p['body'], p['payload']))
        .toList();
  }
}

/// Android implementation of the local notifications plugin.
class AndroidFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback _onSelectNotification;

  /// Initializes the plugin. Call this method on application before using the
  /// plugin further.
  ///
  /// This should only be done once. When a notification created by this plugin
  /// was used to launch the app, calling `initialize` is what will trigger to
  /// the `onSelectNotification` callback to be fire.
  Future<bool> initialize(
    AndroidInitializationSettings initializationSettings, {
    SelectNotificationCallback onSelectNotification,
  }) async {
    _onSelectNotification = onSelectNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  /// Schedules a notification to be shown at the specified date and time.
  ///
  /// The [androidAllowWhileIdle] parameter determines if the notification
  /// should still be shown at the exact time when the device is in a low-power
  /// idle mode.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> schedule(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    AndroidNotificationDetails notificationDetails, {
    String payload,
    bool androidAllowWhileIdle = false,
  }) async {
    validateId(id);
    final Map<String, Object> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    await _channel.invokeMethod('schedule', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'millisecondsSinceEpoch': scheduledDate.millisecondsSinceEpoch,
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? ''
    });
  }

  /// Schedules a notification to be shown at the specified date and time
  /// relative to a specific time zone.
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    TZDateTime scheduledDate,
    AndroidNotificationDetails notificationDetails, {
    @required bool androidAllowWhileIdle,
    String payload,
    ScheduledNotificationRepeatFrequency scheduledNotificationRepeatFrequency,
  }) async {
    validateId(id);
    validateDateIsInTheFuture(scheduledDate);
    ArgumentError.checkNotNull(androidAllowWhileIdle, 'androidAllowWhileIdle');
    final Map<String, Object> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    await _channel.invokeMethod(
        'zonedSchedule',
        <String, Object>{
          'id': id,
          'title': title,
          'body': body,
          'platformSpecifics': serializedPlatformSpecifics,
          'payload': payload ?? ''
        }
          ..addAll(scheduledDate.toMap())
          ..addAll(scheduledNotificationRepeatFrequency == null
              ? <String, Object>{}
              : <String, Object>{
                  'scheduledNotificationRepeatFrequency':
                      scheduledNotificationRepeatFrequency.index
                }));
  }

  /// Shows a notification on a daily interval at the specified time.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> showDailyAtTime(
    int id,
    String title,
    String body,
    Time notificationTime,
    AndroidNotificationDetails notificationDetails, {
    String payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('showDailyAtTime', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.daily.index,
      'repeatTime': notificationTime.toMap(),
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on weekly interval at the specified day and time.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> showWeeklyAtDayAndTime(
    int id,
    String title,
    String body,
    Day day,
    Time notificationTime,
    AndroidNotificationDetails notificationDetails, {
    String payload,
  }) async {
    validateId(id);

    await _channel.invokeMethod('showWeeklyAtDayAndTime', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.weekly.index,
      'repeatTime': notificationTime.toMap(),
      'day': day.value,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  @override
  Future<void> show(
    int id,
    String title,
    String body, {
    AndroidNotificationDetails notificationDetails,
    String payload,
  }) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, Object>{
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
    int id,
    String title,
    String body,
    RepeatInterval repeatInterval, {
    AndroidNotificationDetails notificationDetails,
    String payload,
    bool androidAllowWhileIdle = false,
  }) async {
    validateId(id);
    final Map<String, Object> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    await _channel.invokeMethod('periodicallyShow', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? '',
    });
  }

  /// Creates a notification channel.
  ///
  /// This property is only applicable to Android versions 8.0 or newer.
  Future<void> createNotificationChannel(
          AndroidNotificationChannel notificationChannel) =>
      _channel.invokeMethod(
          'createNotificationChannel', notificationChannel.toMap());

  /// Deletes the notification channel with the specified [channelId].
  Future<void> deleteNotificationChannel(String channelId) =>
      _channel.invokeMethod('deleteNotificationChannel', channelId);

  /// Returns the list of active notifications shown by the application that
  /// haven't been dismissed/removed.
  ///
  /// This method is only applicable to Android 6.0 or newer and will throw an
  /// [PlatformException] when called on a device with an incompatible Android
  /// version.
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final List<Map<Object, Object>> activeNotifications =
        await _channel.invokeListMethod('getActiveNotifications');
    return activeNotifications
        // ignore: always_specify_types
        ?.map((a) => ActiveNotification(
              a['id'],
              a['channelId'],
              a['title'],
              a['body'],
            ))
        ?.toList();
  }

  Future<void> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'selectNotification':
        return _onSelectNotification(call.arguments);
      default:
        return Future<void>.error('Method not defined');
    }
  }
}

/// iOS implementation of the local notifications plugin.
class IOSFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback _onSelectNotification;

  DidReceiveLocalNotificationCallback _onDidReceiveLocalNotification;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
  /// This should only be done once. When a notification created by this plugin
  /// was used to launch the app, calling `initialize` is what will trigger to
  /// the `onSelectNotification` callback to be fire.
  ///
  /// Initialisation may also request notification permissions where users will
  /// see a permissions prompt. This may be fine in cases where it's acceptable
  /// to do this when the application runs for the first time. However, if your
  /// applicationn needs to do this at a later point in time, set the
  /// [IOSInitializationSettings.requestAlertPermission],
  /// [IOSInitializationSettings.requestBadgePermission] and
  /// [IOSInitializationSettings.requestSoundPermission] values to false.
  /// [requestPermissions] can then be called to request permissions when
  /// needed.
  Future<bool> initialize(
    IOSInitializationSettings initializationSettings, {
    SelectNotificationCallback onSelectNotification,
  }) async {
    _onSelectNotification = onSelectNotification;
    _onDidReceiveLocalNotification =
        initializationSettings.onDidReceiveLocalNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  /// Requests the specified permission(s) from user and returns current
  /// permission status.
  Future<bool> requestPermissions({
    bool sound,
    bool alert,
    bool badge,
  }) =>
      _channel.invokeMethod<bool>('requestPermissions', <String, bool>{
        'sound': sound,
        'alert': alert,
        'badge': badge,
      });

  /// Schedules a notification to be shown at the specified date and time with
  /// an optional payload that is passed through when a notification is tapped.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> schedule(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    IOSNotificationDetails notificationDetails, {
    String payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('schedule', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'millisecondsSinceEpoch': scheduledDate.millisecondsSinceEpoch,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Schedules a notification to be shown at the specified time in the
  /// future in a specific time zone.
  ///
  /// Due to the limited support for time zones provided the UILocalNotification
  /// APIs used on devices using iOS versions older than 10, the
  /// [uiLocalNotificationDateInterpretation] is needed to control how
  /// [scheduledDate] is interpreted. See official docs at
  /// https://developer.apple.com/documentation/uikit/uilocalnotification/1616659-timezone
  /// for more details. Note that due to this limited support, it's likely that
  /// on older iOS devices, there will still be issues with daylight savings
  /// except for when the time zone used in the [scheduledDate] matches the
  /// device's time zone and [uiLocalNotificationDateInterpretation] is set to
  /// [UILocalNotificationDateInterpretation.wallClockTime].
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    TZDateTime scheduledDate,
    IOSNotificationDetails notificationDetails, {
    @required
        UILocalNotificationDateInterpretation
            uiLocalNotificationDateInterpretation,
    String payload,
    ScheduledNotificationRepeatFrequency scheduledNotificationRepeatFrequency,
  }) async {
    validateId(id);
    validateDateIsInTheFuture(scheduledDate);
    ArgumentError.checkNotNull(uiLocalNotificationDateInterpretation,
        'uiLocalNotificationDateInterpretation');
    final Map<String, Object> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    await _channel.invokeMethod(
        'zonedSchedule',
        <String, Object>{
          'id': id,
          'title': title,
          'body': body,
          'platformSpecifics': serializedPlatformSpecifics,
          'payload': payload ?? '',
          'uiLocalNotificationDateInterpretation':
              uiLocalNotificationDateInterpretation.index,
        }
          ..addAll(scheduledDate.toMap())
          ..addAll(scheduledNotificationRepeatFrequency == null
              ? <String, Object>{}
              : <String, Object>{
                  'scheduledNotificationRepeatFrequency':
                      scheduledNotificationRepeatFrequency.index
                }));
  }

  /// Shows a notification on a daily interval at the specified time.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> showDailyAtTime(
    int id,
    String title,
    String body,
    Time notificationTime,
    IOSNotificationDetails notificationDetails, {
    String payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('showDailyAtTime', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.daily.index,
      'repeatTime': notificationTime.toMap(),
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Shows a notification on weekly interval at the specified day and time.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> showWeeklyAtDayAndTime(
    int id,
    String title,
    String body,
    Day day,
    Time notificationTime,
    IOSNotificationDetails notificationDetails, {
    String payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('showWeeklyAtDayAndTime', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.weekly.index,
      'repeatTime': notificationTime.toMap(),
      'day': day.value,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  @override
  Future<void> show(
    int id,
    String title,
    String body, {
    IOSNotificationDetails notificationDetails,
    String payload,
  }) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, Object>{
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
    int id,
    String title,
    String body,
    RepeatInterval repeatInterval, {
    IOSNotificationDetails notificationDetails,
    String payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('periodicallyShow', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'selectNotification':
        return _onSelectNotification(call.arguments);

      case 'didReceiveLocalNotification':
        return _onDidReceiveLocalNotification(
            call.arguments['id'],
            call.arguments['title'],
            call.arguments['body'],
            call.arguments['payload']);
      default:
        return Future<void>.error('Method not defined');
    }
  }
}

/// macOS implementation of the local notifications plugin.
class MacOSFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback _onSelectNotification;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
  /// This should only be done once. When a notification created by this plugin
  /// was used to launch the app, calling `initialize` is what will trigger to
  /// the `onSelectNotification` callback to be fire.
  ///
  /// Initialisation may also request notification permissions where users will
  /// see a permissions prompt. This may be fine in cases where it's acceptable
  /// to do this when the application runs for the first time. However, if your
  /// applicationn needs to do this at a later point in time, set the
  /// [MacOSInitializationSettings.requestAlertPermission],
  /// [MacOSInitializationSettings.requestBadgePermission] and
  /// [MacOSInitializationSettings.requestSoundPermission] values to false.
  /// [requestPermissions] can then be called to request permissions when
  /// needed.
  Future<bool> initialize(
    MacOSInitializationSettings initializationSettings, {
    SelectNotificationCallback onSelectNotification,
  }) async {
    _onSelectNotification = onSelectNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  /// Requests the specified permission(s) from user and returns current
  /// permission status.
  Future<bool> requestPermissions({
    bool sound,
    bool alert,
    bool badge,
  }) =>
      _channel.invokeMethod<bool>('requestPermissions', <String, bool>{
        'sound': sound,
        'alert': alert,
        'badge': badge,
      });

  /// Schedules a notification to be shown at the specified date and time
  /// relative to a specific time zone.
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    TZDateTime scheduledDate,
    MacOSNotificationDetails notificationDetails, {
    String payload,
    ScheduledNotificationRepeatFrequency scheduledNotificationRepeatFrequency,
  }) async {
    validateId(id);
    validateDateIsInTheFuture(scheduledDate);
    final Map<String, Object> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    await _channel.invokeMethod(
        'zonedSchedule',
        <String, Object>{
          'id': id,
          'title': title,
          'body': body,
          'platformSpecifics': serializedPlatformSpecifics,
          'payload': payload ?? '',
        }
          ..addAll(scheduledDate.toMap())
          ..addAll(scheduledNotificationRepeatFrequency == null
              ? <String, Object>{}
              : <String, Object>{
                  'scheduledNotificationRepeatFrequency':
                      scheduledNotificationRepeatFrequency.index
                }));
  }

  @override
  Future<void> show(
    int id,
    String title,
    String body, {
    MacOSNotificationDetails notificationDetails,
    String payload,
  }) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, Object>{
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
    int id,
    String title,
    String body,
    RepeatInterval repeatInterval, {
    MacOSNotificationDetails notificationDetails,
    String payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('periodicallyShow', <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': DateTime.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'selectNotification':
        return _onSelectNotification(call.arguments);
      default:
        return Future<void>.error('Method not defined');
    }
  }
}
