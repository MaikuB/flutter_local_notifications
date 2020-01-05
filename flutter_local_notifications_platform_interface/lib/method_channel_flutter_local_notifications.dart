import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('dexterx.dev/flutter_local_notifications');

/// An implementation of the [FlutterLocalNotificationsPlatform] that uses method channels.
class MethodChannelFlutterLocalNotifications
    extends FlutterLocalNotificationsPlatform {
  @override
  Future<void> show(int id, String title, String body, {String payload}) {
    return _channel.invokeMethod<void>('show', <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'payload': payload ?? ''
    });
  }

  @override
  Future<void> cancel(int id) {
    return _channel.invokeMethod<void>('cancel', id);
  }

  @override
  Future<void> cancelAll() {
    return _channel.invokeMethod<void>('cancelAll');
  }
}
