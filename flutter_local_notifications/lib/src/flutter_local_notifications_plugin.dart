import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:platform/platform.dart';

import 'initialization_settings.dart';
import 'notification_details.dart';
import 'platform_flutter_local_notifications.dart';
import 'typedefs.dart';
import 'types.dart';

/// Provides cross-platform functionality for displaying local notifications.
///
/// The plugin will check the platform that is running on to use the appropriate platform-specific
/// implementation of the plugin. The plugin methods will be a no-op when the platform can't be detected.
///
/// Use [resolvePlatformSpecificImplementation] and pass the platform-specific type of the plugin to get the
/// underlying platform-specific implementation if access to platform-specific APIs are needed.
class FlutterLocalNotificationsPlugin {
  factory FlutterLocalNotificationsPlugin() => _instance;

  /// Used internally for creating the appropriate platform-specific implementation of the plugin.
  ///
  /// This can be used for tests as well. For example, the following code
  ///
  /// ```
  /// FlutterLocalNotificationsPlugin.private(FakePlatform(operatingSystem: 'android'))
  /// ```
  ///
  /// could be used in a test needs the plugin to use Android implementation
  @visibleForTesting
  FlutterLocalNotificationsPlugin.private(Platform platform)
      : _platform = platform {
    if (platform.isAndroid) {
      FlutterLocalNotificationsPlatform.instance =
          AndroidFlutterLocalNotificationsPlugin();
    } else if (platform.isIOS) {
      FlutterLocalNotificationsPlatform.instance =
          IOSFlutterLocalNotificationsPlugin();
    }
  }

  static final FlutterLocalNotificationsPlugin _instance =
      FlutterLocalNotificationsPlugin.private(const LocalPlatform());

  final Platform _platform;

  /// Returns the underlying platform-specific implementation of given type [T], which
  /// must be the type of a concrete [FlutterLocalNotificationsPlatform](https://pub.dev/documentation/flutter_local_notifications_platform_interface/latest/flutter_local_notifications_platform_interface/FlutterLocalNotificationsPlatform-class.html) subclass.
  ///
  /// Requires running on the appropriate platform that matches the specified type for a result to be returned.
  /// For example, when the specified type argument is of type [AndroidFlutterLocalNotificationsPlugin],
  /// this will only return a result of that type when running on Android.
  T resolvePlatformSpecificImplementation<
      T extends FlutterLocalNotificationsPlatform>() {
    if (T == FlutterLocalNotificationsPlatform) {
      throw ArgumentError.value(T,
          'The type argument must be a concrete subclass of FlutterLocalNotificationsPlatform');
    }
    if (_platform.isAndroid && T == AndroidFlutterLocalNotificationsPlugin) {
      if (FlutterLocalNotificationsPlatform.instance
          is AndroidFlutterLocalNotificationsPlugin) {
        return FlutterLocalNotificationsPlatform.instance;
      }
    } else if (_platform.isIOS && T == IOSFlutterLocalNotificationsPlugin) {
      if (FlutterLocalNotificationsPlatform.instance
          is IOSFlutterLocalNotificationsPlugin) {
        return FlutterLocalNotificationsPlatform.instance;
      }
    }

    return null;
  }

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further. This should only be done once. When a notification
  /// created by this plugin was used to launch the app, calling `initialize` is what will trigger to the `onSelectNotification`
  /// callback to be fire.
  ///
  /// Will return a [bool] value to indicate if initialization succeeded. On iOS this is dependent on if permissions have been
  /// granted to show notification When running in environment that is neither Android and iOS (e.g. when running tests),
  /// this will be a no-op and return true.
  ///
  /// Note that on iOS, initialisation may also request notification permissions where users will see a permissions prompt.
  /// This may be fine in cases where it's acceptable to do this when the application runs for the first time. However, if your application
  /// needs to do this at a later point in time, set the [IOSInitializationSettings.requestAlertPermission],
  /// [IOSInitializationSettings.requestBadgePermission] and [IOSInitializationSettings.requestSoundPermission] values to false.
  /// [requestPermissions] can then be called to request permissions when needed.
  Future<bool> initialize(InitializationSettings initializationSettings,
      {SelectNotificationCallback onSelectNotification}) async {
    if (_platform.isAndroid) {
      return await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.initialize(initializationSettings?.android,
              onSelectNotification: onSelectNotification);
    } else if (_platform.isIOS) {
      return await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.initialize(initializationSettings?.ios,
              onSelectNotification: onSelectNotification);
    }
    return true;
  }

  /// Returns info on if a notification created from this plugin had been used to launch the application.
  ///
  /// An example of how this could be used is to change the initial route of your application when it starts up.
  /// If the plugin isn't running on either Android or iOS then it defaults to indicate that a notification wasn't
  /// used to launch the app.
  Future<NotificationAppLaunchDetails> getNotificationAppLaunchDetails() async {
    if (_platform.isAndroid) {
      return await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getNotificationAppLaunchDetails();
    } else if (_platform.isIOS) {
      return await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.getNotificationAppLaunchDetails();
    } else {
      return await FlutterLocalNotificationsPlatform.instance
              ?.getNotificationAppLaunchDetails() ??
          NotificationAppLaunchDetails(false, null);
    }
  }

  /// Show a notification with an optional payload that will be passed back to the app when a notification is tapped.
  Future<void> show(int id, String title, String body,
      NotificationDetails notificationDetails,
      {String payload}) async {
    if (_platform.isAndroid) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.android,
              payload: payload);
    } else if (_platform.isIOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.iOS, payload: payload);
    } else {
      await FlutterLocalNotificationsPlatform.instance?.show(id, title, body);
    }
  }

  /// Cancel/remove the notification with the specified id.
  ///
  /// This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancel(int id) async {
    await FlutterLocalNotificationsPlatform.instance?.cancel(id);
  }

  /// Cancels/removes all notifications.
  ///
  /// This applies to notifications that have been scheduled and those that have already been presented.
  Future<void> cancelAll() async {
    await FlutterLocalNotificationsPlatform.instance?.cancelAll();
  }

  /// Schedules a notification to be shown at the specified time with an optional payload that is passed through when a notification is tapped.
  ///
  /// The [androidAllowWhileIdle] parameter is Android-specific and determines if the notification should still be shown at the specified time
  /// even when in a low-power idle mode.
  Future<void> schedule(int id, String title, String body,
      DateTime scheduledDate, NotificationDetails notificationDetails,
      {String payload, bool androidAllowWhileIdle = false}) async {
    if (_platform.isAndroid) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .schedule(
              id, title, body, scheduledDate, notificationDetails?.android,
              payload: payload, androidAllowWhileIdle: androidAllowWhileIdle);
    } else if (_platform.isIOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.schedule(id, title, body, scheduledDate, notificationDetails?.iOS,
              payload: payload);
    }
  }

  /// Periodically show a notification using the specified interval.
  ///
  /// For example, specifying a hourly interval means the first time the notification will be an hour after the method has been called and then every hour after that.
  Future<void> periodicallyShow(int id, String title, String body,
      RepeatInterval repeatInterval, NotificationDetails notificationDetails,
      {String payload}) async {
    if (_platform.isAndroid) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.periodicallyShow(id, title, body, repeatInterval,
              notificationDetails: notificationDetails?.android,
              payload: payload);
    } else if (_platform.isIOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.periodicallyShow(id, title, body, repeatInterval,
              notificationDetails: notificationDetails?.iOS, payload: payload);
    } else {
      await FlutterLocalNotificationsPlatform.instance
          ?.periodicallyShow(id, title, body, repeatInterval);
    }
  }

  /// Shows a notification on a daily interval at the specified time.
  Future<void> showDailyAtTime(int id, String title, String body,
      Time notificationTime, NotificationDetails notificationDetails,
      {String payload}) async {
    if (_platform.isAndroid) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.showDailyAtTime(
              id, title, body, notificationTime, notificationDetails?.android,
              payload: payload);
    } else if (_platform.isIOS) {
      await (FlutterLocalNotificationsPlatform.instance
              as IOSFlutterLocalNotificationsPlugin)
          ?.showDailyAtTime(
              id, title, body, notificationTime, notificationDetails?.iOS,
              payload: payload);
    }
  }

  /// Shows a notification on a daily interval at the specified time.
  Future<void> showWeeklyAtDayAndTime(int id, String title, String body,
      Day day, Time notificationTime, NotificationDetails notificationDetails,
      {String payload}) async {
    if (_platform.isAndroid) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.showWeeklyAtDayAndTime(id, title, body, day, notificationTime,
              notificationDetails?.android,
              payload: payload);
    } else if (_platform.isIOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.showWeeklyAtDayAndTime(
              id, title, body, day, notificationTime, notificationDetails?.iOS,
              payload: payload);
    }
  }

  /// Returns a list of notifications pending to be delivered/shown.
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    return FlutterLocalNotificationsPlatform.instance
        ?.pendingNotificationRequests();
  }
}
