import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:timezone/timezone.dart';

import 'initialization_settings.dart';
import 'notification_details.dart';
import 'platform_flutter_local_notifications.dart';
import 'platform_specifics/android/schedule_mode.dart';
import 'types.dart';
import 'web_flutter_local_notifications.dart';

/// Provides cross-platform functionality for displaying local notifications.
///
/// The plugin will check the platform that is running on to use the appropriate
/// platform-specific implementation of the plugin. The plugin methods will be a
/// no-op when the platform can't be detected.
///
/// Use [resolvePlatformSpecificImplementation] and pass the platform-specific
/// type of the plugin to get the underlying platform-specific implementation
/// if access to platform-specific APIs are needed.
class FlutterLocalNotificationsPlugin {
  /// Factory for create an instance of [FlutterLocalNotificationsPlugin].
  factory FlutterLocalNotificationsPlugin() => _instance;

  FlutterLocalNotificationsPlugin._();

  static final FlutterLocalNotificationsPlugin _instance =
      FlutterLocalNotificationsPlugin._();

  /// Returns the underlying platform-specific implementation of given type [T],
  /// which must be a concrete subclass of [FlutterLocalNotificationsPlatform](https://pub.dev/documentation/flutter_local_notifications_platform_interface/latest/flutter_local_notifications_platform_interface/FlutterLocalNotificationsPlatform-class.html)
  ///
  /// Requires running on the appropriate platform that matches the specified
  /// type for a result to be returned. For example, when the specified type
  /// argument is of type [AndroidFlutterLocalNotificationsPlugin], this will
  /// only return a result of that type when running on Android.
  T? resolvePlatformSpecificImplementation<
      T extends FlutterLocalNotificationsPlatform>() {
    if (T == FlutterLocalNotificationsPlatform) {
      throw ArgumentError.value(
          T,
          'The type argument must be a concrete subclass of '
          'FlutterLocalNotificationsPlatform');
    }

    final FlutterLocalNotificationsPlatform instance =
        FlutterLocalNotificationsPlatform.instance;
    if (kIsWeb && T == WebFlutterLocalNotificationsPlugin && instance is T) {
      return instance;
    } else if (defaultTargetPlatform == TargetPlatform.android &&
        T == AndroidFlutterLocalNotificationsPlugin &&
        instance is T) {
      return instance;
    } else if (defaultTargetPlatform == TargetPlatform.iOS &&
        T == IOSFlutterLocalNotificationsPlugin &&
        instance is T) {
      return instance;
    } else if (defaultTargetPlatform == TargetPlatform.macOS &&
        T == MacOSFlutterLocalNotificationsPlugin &&
        instance is T) {
      return instance;
    } else if (defaultTargetPlatform == TargetPlatform.linux &&
        T == LinuxFlutterLocalNotificationsPlugin &&
        instance is T) {
      return instance;
    } else if (defaultTargetPlatform == TargetPlatform.windows &&
        T == FlutterLocalNotificationsWindows &&
        instance is T) {
      return instance;
    }

    return null;
  }

  /// Initializes the plugin.
  ///
  /// Call this method on application before using the plugin further.
  ///
  /// Will return a [bool] value to indicate if initialization succeeded.
  /// On iOS this is dependent on if permissions have been granted to show
  /// notification When running in environment that is neither Android and
  /// iOS (e.g. when running tests), this will be a no-op and return true.
  ///
  /// Note that on iOS, initialisation may also request notification
  /// permissions where users will see a permissions prompt. This may be fine
  /// in cases where it's acceptable to do this when the application runs for
  /// the first time. However, if your application needs to do this at a later
  /// point in time, set the
  /// [DarwinInitializationSettings.requestAlertPermission],
  /// [DarwinInitializationSettings.requestBadgePermission] and
  /// [DarwinInitializationSettings.requestSoundPermission] values to false.
  /// [IOSFlutterLocalNotificationsPlugin.requestPermissions] can then be called
  /// to request permissions when needed.
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
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    if (kIsWeb) {
      return resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin>()
          ?.initialize();
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (initializationSettings.android == null) {
        throw ArgumentError(
            'Android settings must be set when targeting Android platform.');
      }

      return resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.initialize(
        initializationSettings.android!,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (initializationSettings.iOS == null) {
        throw ArgumentError(
            'iOS settings must be set when targeting iOS platform.');
      }

      return await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.initialize(
        initializationSettings.iOS!,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      if (initializationSettings.macOS == null) {
        throw ArgumentError(
            'macOS settings must be set when targeting macOS platform.');
      }

      return await resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.initialize(
        initializationSettings.macOS!,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      if (initializationSettings.linux == null) {
        throw ArgumentError(
            'Linux settings must be set when targeting Linux platform.');
      }

      return await resolvePlatformSpecificImplementation<
              LinuxFlutterLocalNotificationsPlugin>()
          ?.initialize(
        initializationSettings.linux!,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      if (initializationSettings.windows == null) {
        throw ArgumentError(
            'Windows settings must be set when targeting Windows platform.');
      }

      return await resolvePlatformSpecificImplementation<
              FlutterLocalNotificationsWindows>()
          ?.initialize(
        initializationSettings.windows!,
        onNotificationReceived: onDidReceiveNotificationResponse,
      );
    }
    return true;
  }

  /// Returns info on if a notification created from this plugin had been used
  /// to launch the application.
  ///
  /// An example of how this could be used is to change the initial route of
  /// your application when it starts up. If the plugin isn't running on either
  /// Android, iOS or macOS then an instance of the
  /// `NotificationAppLaunchDetails` class is returned with
  /// `didNotificationLaunchApp` set to false.
  ///
  /// Note that this will return null for applications running on macOS
  /// versions older than 10.14. This is because there's currently no mechanism
  /// for plugins to receive information on lifecycle events.
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    if (kIsWeb) {
      return null;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getNotificationAppLaunchDetails();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.getNotificationAppLaunchDetails();
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return await resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.getNotificationAppLaunchDetails();
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return await resolvePlatformSpecificImplementation<
              FlutterLocalNotificationsWindows>()
          ?.getNotificationAppLaunchDetails();
    } else {
      return await FlutterLocalNotificationsPlatform.instance
              .getNotificationAppLaunchDetails() ??
          const NotificationAppLaunchDetails(false);
    }
  }

  /// Show a notification with an optional payload that will be passed back to
  /// the app when a notification is tapped.
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    if (kIsWeb) {
      await resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin>()
          ?.show(
        id,
        title,
        body,
        payload: payload,
        details: notificationDetails?.web,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.android,
              payload: payload);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.iOS, payload: payload);
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      await resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.macOS,
              payload: payload);
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      await resolvePlatformSpecificImplementation<
              LinuxFlutterLocalNotificationsPlugin>()
          ?.show(id, title, body,
              notificationDetails: notificationDetails?.linux,
              payload: payload);
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      await resolvePlatformSpecificImplementation<
              FlutterLocalNotificationsWindows>()
          ?.show(id, title, body,
              details: notificationDetails?.windows, payload: payload);
    } else {
      await FlutterLocalNotificationsPlatform.instance.show(id, title, body);
    }
  }

  /// Cancel/remove the notification with the specified id.
  ///
  /// This applies to notifications that have been scheduled and those that
  /// have already been presented.
  ///
  /// The `tag` parameter specifies the Android tag. If it is provided,
  /// then the notification that matches both the id and the tag will
  /// be canceled. `tag` has no effect on other platforms.
  Future<void> cancel(int id, {String? tag}) async {
    if (kIsWeb) {
      await resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin>()
          ?.cancel(id, tag: tag);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.cancel(id, tag: tag);
    } else {
      await FlutterLocalNotificationsPlatform.instance.cancel(id);
    }
  }

  /// Cancels/removes all notifications.
  ///
  /// This applies to notifications that have been scheduled and those that
  /// have already been presented.
  Future<void> cancelAll() async {
    await FlutterLocalNotificationsPlatform.instance.cancelAll();
  }

  /// Schedules a notification to be shown at the specified date and time
  /// relative to a specific time zone.
  ///
  /// Note that to get the appropriate representation of the time at the native
  /// level (i.e. Android/iOS), the plugin needs to pass the time over the
  /// platform channel in yyyy-mm-dd hh:mm:ss format. Therefore, the precision
  /// is at the best to the second.
  ///
  /// If a value for [matchDateTimeComponents] parameter is given, this tells
  /// the plugin to schedule a recurring notification that matches the
  /// specified date and time components. Specifying
  /// [DateTimeComponents.time] would result in a daily notification at the
  /// same time whilst [DateTimeComponents.dayOfWeekAndTime] would result
  /// in a weekly notification that occurs on the same day of the week and time.
  /// This is similar to how recurring notifications on iOS/macOS work using a
  /// calendar trigger. Note that when a value is given, the [scheduledDate]
  /// may not represent the first time the notification will be shown. An
  /// example would be if the date and time is currently 2020-10-19 11:00
  /// (i.e. 19th October 2020 11:00AM) and [scheduledDate] is 2020-10-21
  /// 10:00 and the value of the [matchDateTimeComponents] is
  /// [DateTimeComponents.time], then the next time a notification will
  /// appear is 2020-10-20 10:00.
  ///
  /// On Android, this will also require additional setup for the app,
  /// especially in the app's `AndroidManifest.xml` file. Please see check the
  /// readme for further details.
  ///
  /// On Windows, this will only set a notification on the [scheduledDate], and
  /// not repeat, regardless of the value for [matchDateTimeComponents].
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .zonedSchedule(
              id, title, body, scheduledDate, notificationDetails.android,
              payload: payload,
              scheduleMode: androidScheduleMode,
              matchDateTimeComponents: matchDateTimeComponents);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.zonedSchedule(
              id, title, body, scheduledDate, notificationDetails.iOS,
              payload: payload,
              matchDateTimeComponents: matchDateTimeComponents);
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      await resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.zonedSchedule(
              id, title, body, scheduledDate, notificationDetails.macOS,
              payload: payload,
              matchDateTimeComponents: matchDateTimeComponents);
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      await resolvePlatformSpecificImplementation<
              FlutterLocalNotificationsWindows>()
          ?.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails.windows,
        payload: payload,
      );
    } else {
      throw UnimplementedError('zonedSchedule() has not been implemented');
    }
  }

  /// Periodically show a notification using the specified interval.
  ///
  /// For example, specifying a hourly interval means the first time the
  /// notification will be an hour after the method has been called and
  /// then every hour after that.
  ///
  /// On Android, this will also require additional setup for the app,
  /// especially in the app's `AndroidManifest.xml` file. Please see check the
  /// readme for further details.
  Future<void> periodicallyShow(
    int id,
    String? title,
    String? body,
    RepeatInterval repeatInterval,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
  }) async {
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.periodicallyShow(id, title, body, repeatInterval,
              notificationDetails: notificationDetails.android,
              payload: payload,
              scheduleMode: androidScheduleMode);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.periodicallyShow(id, title, body, repeatInterval,
              notificationDetails: notificationDetails.iOS, payload: payload);
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      await resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.periodicallyShow(id, title, body, repeatInterval,
              notificationDetails: notificationDetails.macOS, payload: payload);
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      throw UnsupportedError('Notifications do not repeat on Windows');
    } else {
      await FlutterLocalNotificationsPlatform.instance
          .periodicallyShow(id, title, body, repeatInterval);
    }
  }

  /// Periodically show a notification using the specified custom duration
  /// interval.
  ///
  /// For example, specifying a 5 minutes repeat duration interval means
  /// the first time the notification will be an 5 minutes after the method
  /// has been called and then every 5 minutes after that.
  ///
  /// On Android, this will also require additional setup for the app,
  /// especially in the app's `AndroidManifest.xml` file. Please see check the
  /// readme for further details.
  Future<void> periodicallyShowWithDuration(
    int id,
    String? title,
    String? body,
    Duration repeatDurationInterval,
    NotificationDetails notificationDetails, {
    AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exact,
    String? payload,
  }) async {
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.periodicallyShowWithDuration(
              id, title, body, repeatDurationInterval,
              notificationDetails: notificationDetails.android,
              payload: payload,
              scheduleMode: androidScheduleMode);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.periodicallyShowWithDuration(
              id, title, body, repeatDurationInterval,
              notificationDetails: notificationDetails.iOS, payload: payload);
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      await resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.periodicallyShowWithDuration(
              id, title, body, repeatDurationInterval,
              notificationDetails: notificationDetails.macOS, payload: payload);
    } else {
      await FlutterLocalNotificationsPlatform.instance
          .periodicallyShowWithDuration(
              id, title, body, repeatDurationInterval);
    }
  }

  /// Returns a list of notifications pending to be delivered/shown.
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      FlutterLocalNotificationsPlatform.instance.pendingNotificationRequests();

  /// Returns the list of active notifications shown by the application that
  /// haven't been dismissed/removed.
  ///
  /// The supported OS versions are
  /// - Android: Android 6.0 or newer
  /// - iOS: iOS 10.0 or newer
  /// - macOS: macOS 10.14 or newer
  ///
  /// On Linux it will throw an [UnimplementedError].
  ///
  /// On Windows, your application must be packaged as an MSIX to be able
  /// to use this API. If not, this function will return an empty list.
  /// For more details, see: https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/modernize-wpf-tutorial-5
  Future<List<ActiveNotification>> getActiveNotifications() =>
      FlutterLocalNotificationsPlatform.instance.getActiveNotifications();
}
