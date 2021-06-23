library flutter_local_notifications_web;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

/// A Calculator.
class FlutterLocalNotificationsWeb extends FlutterLocalNotificationsPlatform {

  ///Registers this class as the default instance of [FlutterLocalNotificationsWeb].
  static void registerWith(Registrar registrar) {
    FlutterLocalNotificationsPlatform.instance = FlutterLocalNotificationsWeb();
  }
}
