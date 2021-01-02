import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../flutter_local_notifications.dart';

// ignore_for_file: public_member_api_docs

void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  const EventChannel backgroundChannel =
      EventChannel('dexterous.com/flutter/local_notifications/actions');

  const MethodChannel channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  channel.invokeMethod<int>('getCallbackHandle').then((handle) {
    final NotificationActionCallback callback =
        PluginUtilities.getCallbackFromHandle(
            CallbackHandle.fromRawHandle(handle));

    backgroundChannel
        .receiveBroadcastStream()
        .map<Map<dynamic, dynamic>>((event) => event)
        .map<Map<String, dynamic>>(
            (Map<dynamic, dynamic> event) => Map.castFrom(event))
        .listen((Map<String, dynamic> event) {
      callback(event['id'], event['input'], event['payload']);
    });
  });
}
