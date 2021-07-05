@JS()

library flutter_local_notifications_web;

import 'dart:convert';
import 'package:js/js.dart';
import 'package:import_js_library/import_js_library.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:timezone/timezone.dart';

@JS('show')
external void jshow(int id, String title, String options);

@JS('periodicallyShow')
external void jperiodicallyShow(int id, String title, String body, int milisecs);

///Implementations of flutter_local_notifications web
class FlutterLocalNotificationsWeb extends FlutterLocalNotificationsPlatform {
  ///Registers this class as the default instance of
  ///[FlutterLocalNotificationsWeb].
  static void registerWith(Registrar registrar) {
    FlutterLocalNotificationsPlatform.instance = FlutterLocalNotificationsWeb();
    importJsLibrary(
        url: "./assets/flutter_local_notifications_web.js",
        flutterPluginName: "flutter_local_notifications_web");
  }

  @override
  Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async =>
          Future.value(NotificationAppLaunchDetails(false, null));

  /// Show a notification with an optional payload that will be passed back to
  /// the app when a notification is tapped on.
  Future<void> show(int id, String? title, String? body,
      {NotificationDetails? notificationDetails, String? payload}) async {
    WebNotificationDetails? web = notificationDetails?.web;
    if (web == null) {
      if (notificationDetails?.android != null) {
        web = WebNotificationDetails(
          body: body,
        );
      }
    }
    jshow(id, title ?? '', jsonEncode(web));
  }

  /// Periodically show a notification using the specified interval.
  /// For example, specifying a hourly interval means the first time the
  /// notification will be an hour after the method has been called and then
  /// every hour after that.
  @override
  Future<void> periodicallyShow(int id, String? title, String? body,
      RepeatInterval repeatInterval) async {
    jperiodicallyShow(
      id,
        title!,
        body!,
        repeatInterval == RepeatInterval.everyMinute
            ? 60000
            : repeatInterval == RepeatInterval.hourly
                ? 3600000
            : repeatInterval == RepeatInterval.daily
            ? 86400000
            : 1000
    );
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

  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    SelectNotificationCallback? onSelectNotification,
  }) async =>
      true;

  Future<void> schedule(
    int id,
    String? title,
    String? body,
    DateTime scheduledDate,
    NotificationDetails? notificationDetails, {
    String? payload,
    bool androidAllowWhileIdle = false,
  }) async {
    throw UnimplementedError('schedule() has not been implemented');
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
    throw UnimplementedError('zonedSchedule() has not been implemented');
  }

  @override
  Future<bool?> requestPermissions({
    bool sound = false,
    bool alert = false,
    bool badge = false,
  }) async {
    final NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
    return notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized;
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

  Future<void> deleteNotificationChannel(String channelId) async {
    throw UnimplementedError(
        'deleteNotificationChannel() has not been implemented');
  }
}
