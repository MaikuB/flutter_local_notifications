import 'dart:async';

import 'package:clock/clock.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/timezone.dart';

import 'helpers.dart';
import 'platform_specifics/android/active_notification.dart';
import 'platform_specifics/android/enums.dart';
import 'platform_specifics/android/initialization_settings.dart';
import 'platform_specifics/android/icon.dart';
import 'platform_specifics/android/message.dart';
import 'platform_specifics/android/method_channel_mappers.dart';
import 'platform_specifics/android/notification_channel.dart';
import 'platform_specifics/android/notification_channel_group.dart';
import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/android/notification_sound.dart';
import 'platform_specifics/android/person.dart';
import 'platform_specifics/android/styles/messaging_style_information.dart';
import 'platform_specifics/android/styles/style_information.dart';
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
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('getNotificationAppLaunchDetails');
    return result != null
        ? NotificationAppLaunchDetails(result['notificationLaunchedApp'],
            result.containsKey('payload') ? result['payload'] : null)
        : null;
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    final List<Map<dynamic, dynamic>>? pendingNotifications =
        await _channel.invokeListMethod('pendingNotificationRequests');
    return pendingNotifications
            // ignore: always_specify_types
            ?.map((p) => PendingNotificationRequest(
                p['id'], p['title'], p['body'], p['payload']))
            .toList() ??
        <PendingNotificationRequest>[];
  }
}

/// Android implementation of the local notifications plugin.
class AndroidFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback? _onSelectNotification;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the
  /// plugin further.
  ///
  /// To handle when a notification launched an application, use
  /// [getNotificationAppLaunchDetails].
  Future<bool?> initialize(
    AndroidInitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
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
    String? title,
    String? body,
    DateTime scheduledDate,
    AndroidNotificationDetails? notificationDetails, {
    String? payload,
    bool androidAllowWhileIdle = false,
  }) async {
    validateId(id);
    final Map<String, Object?> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    await _channel.invokeMethod('schedule', <String, Object?>{
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
    String? title,
    String? body,
    TZDateTime scheduledDate,
    AndroidNotificationDetails? notificationDetails, {
    required bool androidAllowWhileIdle,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    validateId(id);
    validateDateIsInTheFuture(scheduledDate, matchDateTimeComponents);
    ArgumentError.checkNotNull(androidAllowWhileIdle, 'androidAllowWhileIdle');
    final Map<String, Object?> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    await _channel.invokeMethod(
        'zonedSchedule',
        <String, Object?>{
          'id': id,
          'title': title,
          'body': body,
          'platformSpecifics': serializedPlatformSpecifics,
          'payload': payload ?? ''
        }
          ..addAll(scheduledDate.toMap())
          ..addAll(matchDateTimeComponents == null
              ? <String, Object>{}
              : <String, Object>{
                  'matchDateTimeComponents': matchDateTimeComponents.index
                }));
  }

  /// Shows a notification on a daily interval at the specified time.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> showDailyAtTime(
    int id,
    String? title,
    String? body,
    Time notificationTime,
    AndroidNotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('showDailyAtTime', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
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
    String? title,
    String? body,
    Day day,
    Time notificationTime,
    AndroidNotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    validateId(id);

    await _channel.invokeMethod('showWeeklyAtDayAndTime', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatInterval': RepeatInterval.weekly.index,
      'repeatTime': notificationTime.toMap(),
      'day': day.value,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  /// Starts an Android foreground service with the given notification.
  ///
  /// The `id` must not be 0, since Android itself does not allow starting
  /// a foreground service with a notification id of 0.
  ///
  /// Since not all users of this plugin need such a service, it was not
  /// added to this plugins Android manifest. Thie means you have to add
  /// it if you want to use the foreground service functionality. Add the
  /// foreground service permission to your apps `AndroidManifest.xml` like
  /// described in the [official Android documentation](https://developer.android.com/guide/components/foreground-services#request-foreground-service-permissions):
  /// ```xml
  /// <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
  /// ```
  /// Furthermore, add the `service` itself to your `AndroidManifest.xml`
  /// (inside the `<application>` tag):
  /// ```xml
  /// <!-- If you want your foreground service to be stopped if
  ///       your app is stopped, set android:stopWithTask to true.
  ///       See https://developer.android.com/reference/android/R.attr#stopWithTask -->
  /// <service
  ///  android:name="com.dexterous.flutterlocalnotifications.ForegroundService"
  ///  android:exported="false"
  ///  android:stopWithTask="false"
  ///  android:foregroundServiceType="As you like" />
  /// ```
  /// While the `android:name` must exactly match this value, you can configure
  /// the other parameters as you like, although it is recommended to copy the
  /// value for `android:exported`. Suitable values for
  /// `foregroundServiceType` can be found [here](https://developer.android.com/reference/android/app/Service#startForeground(int,%20android.app.Notification,%20int)).
  ///
  /// The notification of the foreground service can be updated by
  /// simply calling this method multiple times.
  ///
  /// Information on selecting an appropriate `startType` for your app's usecase
  /// should be taken from the official Android documentation, check [`Service.onStartCommand`](https://developer.android.com/reference/android/app/Service#onStartCommand(android.content.Intent,%20int,%20int)).
  /// The there mentioned constants can be found in [AndroidServiceStartType].
  ///
  /// The notification for the foreground service will not be dismissable
  /// and automatically removed when using [stopForegroundService].
  ///
  /// `foregroundServiceType` is a set of foreground service types to apply to
  /// the service start. It might be `null` or omitted, but it must never
  /// be empty!
  /// If `foregroundServiceType` is set, [`Service.startForeground(int id, Notification notification, int foregroundServiceType)`](https://developer.android.com/reference/android/app/Service#startForeground(int,%20android.app.Notification,%20int))
  /// will be invoked , else  [`Service.startForeground(int id, Notification notification)`](https://developer.android.com/reference/android/app/Service#startForeground(int,%20android.app.Notification)) is used.
  /// On devices older than [`Build.VERSION_CODES.Q`](https://developer.android.com/reference/android/os/Build.VERSION_CODES#Q), `foregroundServiceType` will be ignored.
  /// Note that `foregroundServiceType` (the parameter in this method)
  /// must be a subset of the `android:foregroundServiceType`
  /// defined in your `AndroidManifest.xml` (the one from the section above)!
  Future<void> startForegroundService(int id, String? title, String? body,
      {AndroidNotificationDetails? notificationDetails,
      String? payload,
      AndroidServiceStartType startType = AndroidServiceStartType.startSticky,
      Set<AndroidServiceForegroundType>? foregroundServiceTypes}) {
    validateId(id);
    if (id == 0) {
      throw ArgumentError.value(id, 'id',
          'The id of a notification used for an Android foreground service must not be 0!'); // ignore: lines_longer_than_80_chars
    }
    if (foregroundServiceTypes?.isEmpty ?? false) {
      throw ArgumentError.value(foregroundServiceTypes, 'foregroundServiceType',
          'foregroundServiceType may be null but it must never be empty!');
    }
    return _channel.invokeMethod('startForegroundService', <String, Object?>{
      'notificationData': <String, Object?>{
        'id': id,
        'title': title,
        'body': body,
        'payload': payload ?? '',
        'platformSpecifics': notificationDetails?.toMap(),
      },
      'startType': startType.value,
      'foregroundServiceTypes': foregroundServiceTypes
          ?.map((AndroidServiceForegroundType type) => type.value)
          .toList()
    });
  }

  /// Stops a foreground service.
  ///
  /// If the foreground service was not started, this function
  /// does nothing.
  ///
  /// It is sufficient to call this method once to stop the
  /// foreground service, even if [startForegroundService] was called
  /// multiple times.
  Future<void> stopForegroundService() =>
      _channel.invokeMethod('stopForegroundService');

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    AndroidNotificationDetails? notificationDetails,
    String? payload,
  }) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, Object?>{
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
    String? title,
    String? body,
    RepeatInterval repeatInterval, {
    AndroidNotificationDetails? notificationDetails,
    String? payload,
    bool androidAllowWhileIdle = false,
  }) async {
    validateId(id);
    final Map<String, Object?> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    serializedPlatformSpecifics['allowWhileIdle'] = androidAllowWhileIdle;
    await _channel.invokeMethod('periodicallyShow', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': serializedPlatformSpecifics,
      'payload': payload ?? '',
    });
  }

  /// Cancel/remove the notification with the specified id.
  ///
  /// This applies to notifications that have been scheduled and those that
  /// have already been presented.
  ///
  /// The `tag` parameter specifies the Android tag. If it is provided,
  /// then the notification that matches both the id and the tag will
  /// be canceled. `tag` has no effect on other platforms.
  @override
  Future<void> cancel(int id, {String? tag}) async {
    validateId(id);

    return _channel.invokeMethod('cancel', <String, Object?>{
      'id': id,
      'tag': tag,
    });
  }

  /// Creates a notification channel group.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  Future<void> createNotificationChannelGroup(
          AndroidNotificationChannelGroup notificationChannelGroup) =>
      _channel.invokeMethod(
          'createNotificationChannelGroup', notificationChannelGroup.toMap());

  /// Deletes the notification channel group with the specified [groupId]
  /// as well as all of the channels belonging to the group.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  Future<void> deleteNotificationChannelGroup(String groupId) =>
      _channel.invokeMethod('deleteNotificationChannelGroup', groupId);

  /// Creates a notification channel.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  Future<void> createNotificationChannel(
          AndroidNotificationChannel notificationChannel) =>
      _channel.invokeMethod(
          'createNotificationChannel', notificationChannel.toMap());

  /// Deletes the notification channel with the specified [channelId].
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  Future<void> deleteNotificationChannel(String channelId) =>
      _channel.invokeMethod('deleteNotificationChannel', channelId);

  /// Returns the list of active notifications shown by the application that
  /// haven't been dismissed/removed.
  ///
  /// This method is only applicable to Android 6.0 or newer and will throw an
  /// [PlatformException] when called on a device with an incompatible Android
  /// version.
  Future<List<ActiveNotification>?> getActiveNotifications() async {
    final List<Map<dynamic, dynamic>>? activeNotifications =
        await _channel.invokeListMethod('getActiveNotifications');
    return activeNotifications
        // ignore: always_specify_types
        ?.map((a) => ActiveNotification(
              a['id'],
              a['channelId'],
              a['title'],
              a['body'],
              tag: a['tag'],
            ))
        .toList();
  }

  /// Returns the messaging style information of an active notification shown
  /// by the application that hasn't been dismissed/removed.
  ///
  /// This method is only applicable to Android 6.0 or newer and will throw an
  /// [PlatformException] when called on a device with an incompatible Android
  /// version.
  ///
  /// Only [DrawableResourceAndroidIcon] and [ContentUriAndroidIcon] are
  /// supported for [AndroidIcon] fields.
  Future<MessagingStyleInformation?> getActiveNotificationMessagingStyle(int id, { String? tag }) async {
    final Map<dynamic, dynamic>? m =
        await _channel.invokeMethod('getActiveNotificationMessagingStyle', {
          'id': id,
          'tag': tag,
        });
    if (m == null) {
      return null;
    }

    return MessagingStyleInformation(
      _personFromMap(m['person'])!,
      conversationTitle: m['conversationTitle'],
      groupConversation: m['groupConversation'],
      messages: m['messages']?.map<Message>((m) => _messageFromMap(m))?.toList(),
    );
  }

  Person? _personFromMap(Map<dynamic, dynamic>? m) {
    if (m == null) {
      return null;
    }
    return Person(
      bot: m['bot'],
      icon: _iconFromMap(m['icon']),
      important: m['important'],
      key: m['key'],
      name: m['name'],
      uri: m['uri'],
    );
  }

  Message _messageFromMap(Map<dynamic, dynamic> m) {
    return Message(
      m['text'],
      DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
      _personFromMap(m['person']),
    );
  }

  AndroidIcon<Object>? _iconFromMap(Map<dynamic, dynamic>? m) {
    if (m == null) {
      return null;
    }
    switch (AndroidIconSource.values[m['source']]) {
      case AndroidIconSource.drawableResource:
        return DrawableResourceAndroidIcon(m['data']);
      case AndroidIconSource.contentUri:
        return ContentUriAndroidIcon(m['data']);
      default:
        return null;
    }
  }

  /// Returns the list of all notification channels.
  ///
  /// This method is only applicable on Android 8.0 or newer. On older versions,
  /// it will return an empty list.
  Future<List<AndroidNotificationChannel>?> getNotificationChannels() async {
    final List<Map<dynamic, dynamic>>? notificationChannels =
        await _channel.invokeListMethod('getNotificationChannels');

    return notificationChannels
        // ignore: always_specify_types
        ?.map((a) => AndroidNotificationChannel(
              a['id'],
              a['name'],
              description: a['description'],
              groupId: a['groupId'],
              showBadge: a['showBadge'],
              importance: Importance(a['importance']),
              playSound: a['playSound'],
              sound: _getNotificationChannelSound(a),
              enableLights: a['enableLights'],
              enableVibration: a['enableVibration'],
              vibrationPattern: a['vibrationPattern'],
              ledColor: Color(a['ledColor']),
            ))
        .toList();
  }

  /// Returns whether notifications from the calling package are not blocked.
  Future<bool?> areNotificationsEnabled() async =>
      await _channel.invokeMethod<bool>('areNotificationsEnabled');

  AndroidNotificationSound? _getNotificationChannelSound(
      Map<dynamic, dynamic> channelMap) {
    final int? soundSourceIndex = channelMap['soundSource'];
    AndroidNotificationSound? sound;
    if (soundSourceIndex != null) {
      if (soundSourceIndex ==
          AndroidNotificationSoundSource.rawResource.index) {
        sound = RawResourceAndroidNotificationSound(channelMap['sound']);
      } else if (soundSourceIndex == AndroidNotificationSoundSource.uri.index) {
        sound = UriAndroidNotificationSound(channelMap['sound']);
      }
    }
    return sound;
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'selectNotification':
        _onSelectNotification?.call(call.arguments);
        break;
      default:
        return await Future<void>.error('Method not defined');
    }
  }
}

/// iOS implementation of the local notifications plugin.
class IOSFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback? _onSelectNotification;

  DidReceiveLocalNotificationCallback? _onDidReceiveLocalNotification;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
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
  ///
  /// To handle when a notification launched an application, use
  /// [getNotificationAppLaunchDetails].
  Future<bool?> initialize(
    IOSInitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
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
  Future<bool?> requestPermissions({
    bool sound = false,
    bool alert = false,
    bool badge = false,
  }) =>
      _channel.invokeMethod<bool?>('requestPermissions', <String, bool>{
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
    String? title,
    String? body,
    DateTime scheduledDate,
    IOSNotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('schedule', <String, Object?>{
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
  /// on older iOS devices, there will still be issues with daylight saving time
  /// except for when the time zone used in the [scheduledDate] matches the
  /// device's time zone and [uiLocalNotificationDateInterpretation] is set to
  /// [UILocalNotificationDateInterpretation.wallClockTime].
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    IOSNotificationDetails? notificationDetails, {
    required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    validateId(id);
    validateDateIsInTheFuture(scheduledDate, matchDateTimeComponents);
    ArgumentError.checkNotNull(uiLocalNotificationDateInterpretation,
        'uiLocalNotificationDateInterpretation');
    final Map<String, Object?> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    await _channel.invokeMethod(
        'zonedSchedule',
        <String, Object?>{
          'id': id,
          'title': title,
          'body': body,
          'platformSpecifics': serializedPlatformSpecifics,
          'payload': payload ?? '',
          'uiLocalNotificationDateInterpretation':
              uiLocalNotificationDateInterpretation.index,
        }
          ..addAll(scheduledDate.toMap())
          ..addAll(matchDateTimeComponents == null
              ? <String, Object>{}
              : <String, Object>{
                  'matchDateTimeComponents': matchDateTimeComponents.index
                }));
  }

  /// Shows a notification on a daily interval at the specified time.
  @Deprecated(
      'Deprecated due to problems with time zones. Use zonedSchedule instead.')
  Future<void> showDailyAtTime(
    int id,
    String? title,
    String? body,
    Time notificationTime,
    IOSNotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('showDailyAtTime', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
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
    String? title,
    String? body,
    Day day,
    Time notificationTime,
    IOSNotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('showWeeklyAtDayAndTime', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
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
    String? title,
    String? body, {
    IOSNotificationDetails? notificationDetails,
    String? payload,
  }) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, Object?>{
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
    String? title,
    String? body,
    RepeatInterval repeatInterval, {
    IOSNotificationDetails? notificationDetails,
    String? payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('periodicallyShow', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'selectNotification':
        _onSelectNotification?.call(call.arguments);
        break;
      case 'didReceiveLocalNotification':
        _onDidReceiveLocalNotification!(
            call.arguments['id'],
            call.arguments['title'],
            call.arguments['body'],
            call.arguments['payload']);
        break;
      default:
        return await Future<void>.error('Method not defined');
    }
  }
}

/// macOS implementation of the local notifications plugin.
class MacOSFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  SelectNotificationCallback? _onSelectNotification;

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
  ///
  /// To handle when a notification launched an application, use
  /// [getNotificationAppLaunchDetails].
  Future<bool?> initialize(
    MacOSInitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
  }) async {
    _onSelectNotification = onSelectNotification;
    _channel.setMethodCallHandler(_handleMethod);
    return await _channel.invokeMethod(
        'initialize', initializationSettings.toMap());
  }

  /// Requests the specified permission(s) from user and returns current
  /// permission status.
  Future<bool?> requestPermissions({
    bool? sound,
    bool? alert,
    bool? badge,
  }) =>
      _channel.invokeMethod<bool>('requestPermissions', <String, bool?>{
        'sound': sound,
        'alert': alert,
        'badge': badge,
      });

  /// Schedules a notification to be shown at the specified date and time
  /// relative to a specific time zone.
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    MacOSNotificationDetails? notificationDetails, {
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    validateId(id);
    validateDateIsInTheFuture(scheduledDate, matchDateTimeComponents);
    final Map<String, Object?> serializedPlatformSpecifics =
        notificationDetails?.toMap() ?? <String, Object>{};
    await _channel.invokeMethod(
        'zonedSchedule',
        <String, Object?>{
          'id': id,
          'title': title,
          'body': body,
          'platformSpecifics': serializedPlatformSpecifics,
          'payload': payload ?? '',
        }
          ..addAll(scheduledDate.toMap())
          ..addAll(matchDateTimeComponents == null
              ? <String, Object>{}
              : <String, Object>{
                  'matchDateTimeComponents': matchDateTimeComponents.index
                }));
  }

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    MacOSNotificationDetails? notificationDetails,
    String? payload,
  }) {
    validateId(id);
    return _channel.invokeMethod(
      'show',
      <String, Object?>{
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
    String? title,
    String? body,
    RepeatInterval repeatInterval, {
    MacOSNotificationDetails? notificationDetails,
    String? payload,
  }) async {
    validateId(id);
    await _channel.invokeMethod('periodicallyShow', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'selectNotification':
        _onSelectNotification?.call(call.arguments);
        break;
      default:
        return await Future<void>.error('Method not defined');
    }
  }
}
