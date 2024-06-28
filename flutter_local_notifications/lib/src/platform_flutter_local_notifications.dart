import 'dart:async';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/timezone.dart';

import 'callback_dispatcher.dart';
import 'helpers.dart';
import 'platform_specifics/android/enums.dart';
import 'platform_specifics/android/icon.dart';
import 'platform_specifics/android/initialization_settings.dart';
import 'platform_specifics/android/message.dart';
import 'platform_specifics/android/method_channel_mappers.dart';
import 'platform_specifics/android/notification_channel.dart';
import 'platform_specifics/android/notification_channel_group.dart';
import 'platform_specifics/android/notification_details.dart';
import 'platform_specifics/android/notification_sound.dart';
import 'platform_specifics/android/person.dart';
import 'platform_specifics/android/schedule_mode.dart';
import 'platform_specifics/android/styles/messaging_style_information.dart';
import 'platform_specifics/darwin/initialization_settings.dart';
import 'platform_specifics/darwin/mappers.dart';
import 'platform_specifics/darwin/notification_details.dart';
import 'platform_specifics/darwin/notification_enabled_options.dart';
import 'platform_specifics/ios/enums.dart';
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
    final Map<dynamic, dynamic>? notificationResponse =
        result != null && result.containsKey('notificationResponse')
            ? result['notificationResponse']
            : null;
    return result != null
        ? NotificationAppLaunchDetails(
            result['notificationLaunchedApp'],
            notificationResponse: notificationResponse == null
                ? null
                : NotificationResponse(
                    id: notificationResponse['notificationId'],
                    actionId: notificationResponse['actionId'],
                    input: notificationResponse['input'],
                    notificationResponseType: NotificationResponseType.values[
                        notificationResponse['notificationResponseType']],
                    payload: notificationResponse.containsKey('payload')
                        ? notificationResponse['payload']
                        : null,
                  ),
          )
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

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final List<Map<dynamic, dynamic>>? activeNotifications =
        await _channel.invokeListMethod('getActiveNotifications');
    return activeNotifications
            // ignore: always_specify_types
            ?.map((p) => ActiveNotification(
                  id: p['id'],
                  channelId: p['channelId'],
                  groupKey: p['groupKey'],
                  tag: p['tag'],
                  title: p['title'],
                  body: p['body'],
                  payload: p['payload'],
                  bigText: p['bigText'],
                ))
            .toList() ??
        <ActiveNotification>[];
  }
}

/// Android implementation of the local notifications plugin.
class AndroidFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  DidReceiveNotificationResponseCallback? _ondidReceiveNotificationResponse;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the
  /// plugin further.
  ///
  /// The [onDidReceiveNotificationResponse] callback is fired when the user
  /// selects a notification or notification action that should show the
  /// application/user interface.
  /// application was running. To handle when a notification launched an
  /// application, use [getNotificationAppLaunchDetails]. For notification
  /// actions that don't show the application/user interface, the
  /// [onDidReceiveBackgroundNotificationResponse] callback is invoked on
  /// a background isolate. Functions passed to the
  /// [onDidReceiveBackgroundNotificationResponse]
  /// callback need to be annotated with the `@pragma('vm:entry-point')`
  /// annotation to ensure they are not stripped out by the Dart compiler.
  Future<bool> initialize(
    AndroidInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    _ondidReceiveNotificationResponse = onDidReceiveNotificationResponse;
    _channel.setMethodCallHandler(_handleMethod);

    final Map<String, Object> arguments = initializationSettings.toMap();

    _evaluateBackgroundNotificationCallback(
        onDidReceiveBackgroundNotificationResponse, arguments);

    return await _channel.invokeMethod('initialize', arguments);
  }

  /// Requests the permission to schedule exact alarms.
  ///
  /// Returns whether the permission was granted.
  ///
  /// Use this when your application requires the [`SCHEDULE_EXACT_ALARM`](https://developer.android.com/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM)
  /// permission and targets Android 13 or higher. The reason for this is that
  /// applications meeting this criteria that run on Android 14 or higher will
  /// require the user to grant permission. See [here](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms)
  /// for official Android documentation.
  Future<bool?> requestExactAlarmsPermission() async =>
      _channel.invokeMethod<bool>('requestExactAlarmsPermission');

  /// Requests the permission to send/use full-screen intents.
  ///
  /// Returns whether the permission was granted.
  ///
  /// Use this when your application requires the [`USE_FULL_SCREEN_INTENT`](https://developer.android.com/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM)
  /// permission and targets Android 14 or higher. The reason for this is that
  /// the permission is granted by default. However, applications that do not
  /// have calling or alarm functionalities have the permission revoked by the
  /// Google Play Store. See
  /// [here](https://source.android.com/docs/core/permissions/fsi-limits)
  /// for official Android documentation.
  Future<bool?> requestFullScreenIntentPermission() async =>
      _channel.invokeMethod<bool>('requestFullScreenIntentPermission');

  /// Requests the permission for sending notifications. Returns whether the
  /// permission was granted.
  ///
  /// Requests the `POST_NOTIFICATIONS` permission on Android 13 Tiramisu (API
  /// level 33) and newer. On older versions, it is a no-op.
  ///
  /// See also:
  ///
  ///  * https://developer.android.com/about/versions/13/changes/notification-permission
  Future<bool?> requestNotificationsPermission() async =>
      _channel.invokeMethod<bool>('requestNotificationsPermission');

  /// Schedules a notification to be shown at the specified date and time
  /// relative to a specific time zone.
  ///
  /// The [scheduleMode] parameter defines the precision of the timing for the
  /// notification to be appear.
  ///
  /// This will also require additional setup for the app, especially in the
  /// app's `AndroidManifest.xml` file. Please see check the readme for further
  /// details.
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    AndroidNotificationDetails? notificationDetails, {
    required AndroidScheduleMode scheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    validateId(id);
    validateDateIsInTheFuture(scheduledDate, matchDateTimeComponents);

    await _channel.invokeMethod(
      'zonedSchedule',
      <String, Object?>{
        'id': id,
        'title': title,
        'body': body,
        'platformSpecifics':
            _buildPlatformSpecifics(notificationDetails, scheduleMode),
        'payload': payload ?? '',
        ...scheduledDate.toMap(),
        if (matchDateTimeComponents != null)
          'matchDateTimeComponents': matchDateTimeComponents.index
      },
    );
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
      'startType': startType.index,
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

  /// Periodically show a notification using the specified interval.
  ///
  /// For example, specifying a hourly interval means the first time the
  /// notification will be an hour after the method has been called and
  /// then every hour after that.
  ///
  /// This will also require additional setup for the app, especially in the
  /// app's `AndroidManifest.xml` file. Please see check the readme for further
  /// details.
  @override
  Future<void> periodicallyShow(
    int id,
    String? title,
    String? body,
    RepeatInterval repeatInterval, {
    AndroidNotificationDetails? notificationDetails,
    String? payload,
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exact,
  }) async {
    validateId(id);
    await _channel.invokeMethod('periodicallyShow', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatInterval': repeatInterval.index,
      'platformSpecifics':
          _buildPlatformSpecifics(notificationDetails, scheduleMode),
      'payload': payload ?? '',
    });
  }

  @override
  Future<void> periodicallyShowWithDuration(
    int id,
    String? title,
    String? body,
    Duration repeatDurationInterval, {
    AndroidNotificationDetails? notificationDetails,
    String? payload,
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exact,
  }) async {
    validateId(id);
    validateRepeatDurationInterval(repeatDurationInterval);
    await _channel
        .invokeMethod('periodicallyShowWithDuration', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatIntervalMilliseconds': repeatDurationInterval.inMilliseconds,
      'platformSpecifics':
          _buildPlatformSpecifics(notificationDetails, scheduleMode),
      'payload': payload ?? '',
    });
  }

  Map<String, Object?> _buildPlatformSpecifics(
    AndroidNotificationDetails? notificationDetails,
    AndroidScheduleMode scheduleMode,
  ) =>
      <String, Object?>{
        if (notificationDetails != null) ...notificationDetails.toMap(),
        'scheduleMode': scheduleMode.name,
      };

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

  /// Returns the messaging style information of an active notification shown
  /// by the application that hasn't been dismissed/removed.
  ///
  /// This method is only applicable to Android 6.0 or newer and will throw an
  /// [PlatformException] when called on a device with an incompatible Android
  /// version.
  ///
  /// Only [DrawableResourceAndroidIcon] and [ContentUriAndroidIcon] are
  /// supported for [AndroidIcon] fields.
  Future<MessagingStyleInformation?> getActiveNotificationMessagingStyle(
    int id, {
    String? tag,
  }) async {
    final Map<dynamic, dynamic>? m = await _channel
        .invokeMethod('getActiveNotificationMessagingStyle', <String, Object?>{
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
      messages:
          // ignore: always_specify_types
          m['messages']?.map<Message>((m) => _messageFromMap(m))?.toList(),
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

  Message _messageFromMap(Map<dynamic, dynamic> m) => Message(
        m['text'],
        DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
        _personFromMap(m['person']),
      );

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
              importance: Importance.values
                  // ignore: always_specify_types
                  .firstWhere((i) => i.value == a['importance']),
              playSound: a['playSound'],
              sound: _getNotificationChannelSound(a),
              enableLights: a['enableLights'],
              enableVibration: a['enableVibration'],
              vibrationPattern: a['vibrationPattern'],
              ledColor: Color(a['ledColor']),
              audioAttributesUsage: AudioAttributesUsage.values.firstWhere(
                // ignore: always_specify_types
                (e) => e.value == a['audioAttributesUsage'],
                orElse: () => AudioAttributesUsage.notification,
              ),
            ))
        .toList();
  }

  /// Returns whether the app can post notifications.
  ///
  /// On Android 13 Tiramisu (API level 33) and newer, this returns whether the
  /// `POST_NOTIFICATIONS` permission is granted. On older versions, it returns
  /// whether the notifications are enabled (which they are by default).
  ///
  /// See also:
  ///
  ///  * https://developer.android.com/about/versions/13/changes/notification-permission
  Future<bool?> areNotificationsEnabled() async =>
      await _channel.invokeMethod<bool>('areNotificationsEnabled');

  /// Returns whether the app can schedule exact notifications.
  Future<bool?> canScheduleExactNotifications() async =>
      await _channel.invokeMethod<bool>('canScheduleExactNotifications');

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
      case 'didReceiveNotificationResponse':
        _ondidReceiveNotificationResponse?.call(
          NotificationResponse(
            id: call.arguments['notificationId'],
            actionId: call.arguments['actionId'],
            input: call.arguments['input'],
            payload: call.arguments['payload'],
            notificationResponseType: NotificationResponseType
                .values[call.arguments['notificationResponseType']],
          ),
        );
        break;
      default:
        return await Future<void>.error('Method not defined');
    }
  }
}

/// iOS implementation of the local notifications plugin.
class IOSFlutterLocalNotificationsPlugin
    extends MethodChannelFlutterLocalNotificationsPlugin {
  DidReceiveNotificationResponseCallback? _onDidReceiveNotificationResponse;
  DidReceiveLocalNotificationCallback? _onDidReceiveLocalNotification;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
  ///
  /// Initialisation may also request notification permissions where users will
  /// see a permissions prompt. This may be fine in cases where it's acceptable
  /// to do this when the application runs for the first time. However, if your
  /// application needs to do this at a later point in time, set the
  /// [DarwinInitializationSettings.requestAlertPermission],
  /// [DarwinInitializationSettings.requestBadgePermission] and
  /// [DarwinInitializationSettings.requestSoundPermission] and
  /// [DarwinInitializationSettings.requestProvisionalPermission] values to
  /// false.
  /// [requestPermissions] can then be called to request permissions when
  /// needed.
  ///
  /// The [onDidReceiveNotificationResponse] callback is fired when the user
  /// selects a notification or notification action that should show the
  /// application/user interface.
  /// application was running. To handle when a notification launched an
  /// application, use [getNotificationAppLaunchDetails]. For notification
  /// actions that don't show the application/user interface, the
  /// [onDidReceiveBackgroundNotificationResponse] callback is invoked on
  /// a background isolate. Functions passed to the
  /// [onDidReceiveBackgroundNotificationResponse]
  /// callback need to be annotated with the `@pragma('vm:entry-point')`
  /// annotation to ensure they are not stripped out by the Dart compiler.
  Future<bool?> initialize(
    DarwinInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    _onDidReceiveNotificationResponse = onDidReceiveNotificationResponse;
    _onDidReceiveLocalNotification =
        initializationSettings.onDidReceiveLocalNotification;
    _channel.setMethodCallHandler(_handleMethod);

    final Map<String, Object> arguments = initializationSettings.toMap();

    _evaluateBackgroundNotificationCallback(
        onDidReceiveBackgroundNotificationResponse, arguments);

    return await _channel.invokeMethod('initialize', arguments);
  }

  /// Requests the specified permission(s) from user and returns current
  /// permission status.
  Future<bool?> requestPermissions({
    bool sound = false,
    bool alert = false,
    bool badge = false,
    bool provisional = false,
    bool critical = false,
  }) =>
      _channel.invokeMethod<bool?>('requestPermissions', <String, bool>{
        'sound': sound,
        'alert': alert,
        'badge': badge,
        'provisional': provisional,
        'critical': critical,
      });

  /// Returns whether the app can post notifications and what kind of.
  ///
  /// See [NotificationsEnabledOptions] for more info.
  Future<NotificationsEnabledOptions?> checkPermissions() =>
      _channel.invokeMethod<Map<dynamic, dynamic>?>('checkPermissions').then(
        (Map<dynamic, dynamic>? dict) {
          if (dict == null) {
            return null;
          }

          return NotificationsEnabledOptions(
            isEnabled: dict['isEnabled'] ?? false,
            isAlertEnabled: dict['isAlertEnabled'] ?? false,
            isBadgeEnabled: dict['isBadgeEnabled'] ?? false,
            isSoundEnabled: dict['isSoundEnabled'] ?? false,
            isProvisionalEnabled: dict['isProvisionalEnabled'] ?? false,
            isCriticalEnabled: dict['isCriticalEnabled'] ?? false,
          );
        },
      );

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
    DarwinNotificationDetails? notificationDetails, {
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

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    DarwinNotificationDetails? notificationDetails,
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
    DarwinNotificationDetails? notificationDetails,
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

  @override
  Future<void> periodicallyShowWithDuration(
    int id,
    String? title,
    String? body,
    Duration repeatDurationInterval, {
    DarwinNotificationDetails? notificationDetails,
    String? payload,
  }) async {
    validateId(id);
    validateRepeatDurationInterval(repeatDurationInterval);
    await _channel
        .invokeMethod('periodicallyShowWithDuration', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatIntervalMilliseconds': repeatDurationInterval.inMilliseconds,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'didReceiveNotificationResponse':
        _onDidReceiveNotificationResponse?.call(
          NotificationResponse(
            id: call.arguments['notificationId'],
            actionId: call.arguments['actionId'],
            input: call.arguments['input'],
            payload: call.arguments['payload'],
            notificationResponseType: NotificationResponseType
                .values[call.arguments['notificationResponseType']],
          ),
        );
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
  DidReceiveNotificationResponseCallback? _onDidReceiveNotificationResponse;

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
  /// This should only be done once.
  ///
  /// Initialisation may also request notification permissions where users will
  /// see a permissions prompt. This may be fine in cases where it's acceptable
  /// to do this when the application runs for the first time. However, if your
  /// application needs to do this at a later point in time, set the
  /// [DarwinInitializationSettings.requestAlertPermission],
  /// [DarwinInitializationSettings.requestBadgePermission] and
  /// [DarwinInitializationSettings.requestSoundPermission] values to false.
  /// [requestPermissions] can then be called to request permissions when
  /// needed.
  ///
  /// The [onDidReceiveNotificationResponse] callback is fired when the user
  /// interacts with a notification that was displayed by the plugin and the
  /// application was running. To handle when a notification launched an
  /// application, use [getNotificationAppLaunchDetails].
  Future<bool?> initialize(
    DarwinInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    _onDidReceiveNotificationResponse = onDidReceiveNotificationResponse;
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
    bool provisional = false,
    bool critical = false,
  }) =>
      _channel.invokeMethod<bool>('requestPermissions', <String, bool?>{
        'sound': sound,
        'alert': alert,
        'badge': badge,
        'provisional': provisional,
        'critical': critical,
      });

  /// Returns whether the app can post notifications and what kind of.
  ///
  /// See [NotificationsEnabledOptions] for more info.
  Future<NotificationsEnabledOptions?> checkPermissions() => _channel
          .invokeMethod<Map<dynamic, dynamic>>('checkPermissions')
          .then((Map<dynamic, dynamic>? dict) {
        if (dict == null) {
          return null;
        }

        return NotificationsEnabledOptions(
          isEnabled: dict['isEnabled'] ?? false,
          isAlertEnabled: dict['isAlertEnabled'] ?? false,
          isBadgeEnabled: dict['isBadgeEnabled'] ?? false,
          isSoundEnabled: dict['isSoundEnabled'] ?? false,
          isProvisionalEnabled: dict['isProvisionalEnabled'] ?? false,
          isCriticalEnabled: dict['isCriticalEnabled'] ?? false,
        );
      });

  /// Schedules a notification to be shown at the specified date and time
  /// relative to a specific time zone.
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    DarwinNotificationDetails? notificationDetails, {
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
    DarwinNotificationDetails? notificationDetails,
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
    DarwinNotificationDetails? notificationDetails,
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

  @override
  Future<void> periodicallyShowWithDuration(
    int id,
    String? title,
    String? body,
    Duration repeatDurationInterval, {
    DarwinNotificationDetails? notificationDetails,
    String? payload,
  }) async {
    validateId(id);
    validateRepeatDurationInterval(repeatDurationInterval);
    await _channel
        .invokeMethod('periodicallyShowWithDuration', <String, Object?>{
      'id': id,
      'title': title,
      'body': body,
      'calledAt': clock.now().millisecondsSinceEpoch,
      'repeatIntervalMilliseconds': repeatDurationInterval.inMilliseconds,
      'platformSpecifics': notificationDetails?.toMap(),
      'payload': payload ?? ''
    });
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'didReceiveNotificationResponse':
        _onDidReceiveNotificationResponse?.call(
          NotificationResponse(
            id: call.arguments['notificationId'],
            actionId: call.arguments['actionId'],
            input: call.arguments['input'],
            payload: call.arguments['payload'],
            notificationResponseType: NotificationResponseType
                .values[call.arguments['notificationResponseType']],
          ),
        );
        break;
      default:
        return await Future<void>.error('Method not defined');
    }
  }
}

/// Checks [didReceiveBackgroundNotificationResponseCallback], if not `null`,
/// for eligibility to be used as a background callback.
///
/// If the method is `null`, no further action will be taken.
///
/// This will add a `dispatcher_handle` and `callback_handle` argument to the
/// [arguments] map when the config is correct.
void _evaluateBackgroundNotificationCallback(
  DidReceiveBackgroundNotificationResponseCallback?
      didReceiveBackgroundNotificationResponseCallback,
  Map<String, Object> arguments,
) {
  if (didReceiveBackgroundNotificationResponseCallback != null) {
    final CallbackHandle? callback = PluginUtilities.getCallbackHandle(
        didReceiveBackgroundNotificationResponseCallback);
    assert(callback != null, '''
          The backgroundHandler needs to be either a static function or a top 
          level function to be accessible as a Flutter entry point.''');

    final CallbackHandle? dispatcher =
        PluginUtilities.getCallbackHandle(callbackDispatcher);

    arguments['dispatcher_handle'] = dispatcher!.toRawHandle();
    arguments['callback_handle'] = callback!.toRawHandle();
  }
}
