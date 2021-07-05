import 'package:flutter_local_notifications_platform_interface/src/initialization_settings.dart';
import 'package:flutter_local_notifications_platform_interface/src/notification_details.dart';
import 'package:flutter_local_notifications_platform_interface/src/platform_flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/src/platform_specifics/android/active_notification.dart';
import 'package:flutter_local_notifications_platform_interface/src/platform_specifics/android/notification_channel.dart';
import 'package:flutter_local_notifications_platform_interface/src/platform_specifics/android/notification_channel_group.dart';
import 'package:flutter_local_notifications_platform_interface/src/platform_specifics/ios/enums.dart';
import 'package:flutter_local_notifications_platform_interface/src/typedefs.dart';
import 'package:platform/platform.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:timezone/timezone.dart';

import 'src/notification_app_launch_details.dart';
import 'src/types.dart';

export 'package:flutter_local_notifications_platform_interface/src/platform_flutter_local_notifications.dart'
    hide MethodChannelFlutterLocalNotificationsPlugin;

export 'src/initialization_settings.dart';
export 'src/notification_app_launch_details.dart';
export 'src/notification_details.dart';
export 'src/platform_specifics/android/active_notification.dart';
export 'src/platform_specifics/android/bitmap.dart';
export 'src/platform_specifics/android/enums.dart'
    hide AndroidBitmapSource, AndroidIconSource, AndroidNotificationSoundSource;
export 'src/platform_specifics/android/icon.dart' hide AndroidIcon;
export 'src/platform_specifics/android/initialization_settings.dart';
export 'src/platform_specifics/android/message.dart';
export 'src/platform_specifics/android/method_channel_mappers.dart';
export 'src/platform_specifics/android/notification_channel.dart';
export 'src/platform_specifics/android/notification_channel_group.dart';
export 'src/platform_specifics/android/notification_details.dart';
export 'src/platform_specifics/android/notification_sound.dart';
export 'src/platform_specifics/android/person.dart';
export 'src/platform_specifics/android/styles/big_picture_style_information.dart';
export 'src/platform_specifics/android/styles/big_text_style_information.dart';
export 'src/platform_specifics/android/styles/default_style_information.dart';
export 'src/platform_specifics/android/styles/inbox_style_information.dart';
export 'src/platform_specifics/android/styles/media_style_information.dart';
export 'src/platform_specifics/android/styles/messaging_style_information.dart';
export 'src/platform_specifics/ios/enums.dart';
export 'src/platform_specifics/ios/initialization_settings.dart';
export 'src/platform_specifics/ios/notification_attachment.dart';
export 'src/platform_specifics/ios/notification_details.dart';
export 'src/platform_specifics/macos/initialization_settings.dart';
export 'src/platform_specifics/macos/notification_attachment.dart';
export 'src/platform_specifics/macos/notification_details.dart';
export 'src/platform_specifics/web/notification_details.dart';
export 'src/typedefs.dart';
export 'src/types.dart';

/// The interface that all implementations of flutter_local_notifications must
/// implement.
abstract class FlutterLocalNotificationsPlatform extends PlatformInterface {
  /// Constructs an instance of [FlutterLocalNotificationsPlatform].
  FlutterLocalNotificationsPlatform() : super(token: _token);


  static FlutterLocalNotificationsPlatform? init() {
    var platform = const LocalPlatform();
    FlutterLocalNotificationsPlatform? instance;
    if (platform.isAndroid) {
      instance =
          AndroidFlutterLocalNotificationsPlugin();
    } else if (platform.isIOS) {
      instance =
          IOSFlutterLocalNotificationsPlugin();
    } else if (platform.isMacOS) {
      instance =
          MacOSFlutterLocalNotificationsPlugin();
    }
    return instance;
  }

  static FlutterLocalNotificationsPlatform _instance = init()!;

  static final Object _token = Object();

  /// The default instance of [FlutterLocalNotificationsPlatform] to use.
  static FlutterLocalNotificationsPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterLocalNotificationsPlatform] when they register
  /// themselves.
  static set instance(FlutterLocalNotificationsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns info on if a notification had been used to launch the application.
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    throw UnimplementedError(
        'getNotificationAppLaunchDetails() has not been implemented');
  }

  /// Show a notification with an optional payload that will be passed back to
  /// the app when a notification is tapped on.
  Future<void> show(int id, String? title, String? body,
      {NotificationDetails? notificationDetails ,
      String? payload}) async {
    throw UnimplementedError('show() has not been implemented');
  }

  /// Periodically show a notification using the specified interval.
  /// For example, specifying a hourly interval means the first time the
  /// notification will be an hour after the method has been called and then
  /// every hour after that.
  Future<void> periodicallyShow(
      int id, String? title, String? body, RepeatInterval repeatInterval) {
    throw UnimplementedError('periodicallyShow() has not been implemented');
  }

  /// Cancel/remove the notification with the specified id.
  ///
  /// This applies to notifications that have been scheduled and those that
  /// have already been presented.
  Future<void> cancel(int id) async {
    throw UnimplementedError('cancel() has not been implemented');
  }

  /// Cancels/removes all notifications. This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancelAll() async {
    throw UnimplementedError('cancelAll() has not been implemented');
  }

  /// Returns a list of notifications pending to be delivered/shown
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    throw UnimplementedError(
        'pendingNotificationRequest() has not been implemented');
  }

  Future<bool?> initialize(
      InitializationSettings initializationSettings, {
        SelectNotificationCallback? onSelectNotification,
      }) async {
    throw UnimplementedError(
        'initialize() has not been implemented');
  }

  Future<void> schedule(
      int id,
      String? title,
      String? body,
      DateTime scheduledDate,
      NotificationDetails? notificationDetails, {
        String? payload,
        bool androidAllowWhileIdle = false,
      }) async {
    throw UnimplementedError(
        'schedule() has not been implemented');
  }

  Future<void> zonedSchedule(
      int id,
      String? title,
      String? body,
      TZDateTime scheduledDate,
      NotificationDetails? notificationDetails, {
        required bool androidAllowWhileIdle,
        required UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation,
        String? payload,
        DateTimeComponents? matchDateTimeComponents,
      }) async {
    throw UnimplementedError(
        'zonedSchedule() has not been implemented');
  }

  Future<bool?> requestPermissions({
    bool sound = false,
    bool alert = false,
    bool badge = false,
  }) async {
    throw UnimplementedError(
        'requestPermissions() has not been implemented');
  }

  Future<List<ActiveNotification>?> getActiveNotifications() async {
    throw UnimplementedError(
        'getActiveNotifications() has not been implemented');
  }

  Future<List<AndroidNotificationChannel>?> getNotificationChannels() async {
    throw UnimplementedError(
        'getNotificationChannels() has not been implemented');
  }

  Future<void> createNotificationChannelGroup(
      AndroidNotificationChannelGroup notificationChannelGroup) async {
    throw UnimplementedError(
        'createNotificationChannelGroup() has not been implemented');
  }

  Future<void> createNotificationChannel(
      AndroidNotificationChannel notificationChannel) async {
    throw UnimplementedError(
        'createNotificationChannelGroup() has not been implemented');
  }

  Future<void> deleteNotificationChannelGroup(String groupId) async {
    throw UnimplementedError(
        'deleteNotificationChannelGroup() has not been implemented');
  }

  Future<void> deleteNotificationChannel(String channelId)  async {
    throw UnimplementedError(
        'deleteNotificationChannel() has not been implemented');
  }


}
