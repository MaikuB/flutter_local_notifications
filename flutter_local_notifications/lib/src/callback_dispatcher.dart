import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  const EventChannel backgroundChannel =
      EventChannel('dexterous.com/flutter/local_notifications/actions');

  const MethodChannel channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  channel.invokeMethod<int>('getCallbackHandle').then((handle) {
    final Function callback = PluginUtilities.getCallbackFromHandle(
        CallbackHandle.fromRawHandle(handle));

    backgroundChannel
        .receiveBroadcastStream()
        .map<Map<dynamic, dynamic>>((event) => event)
        .map<Map<String, dynamic>>((event) => Map.castFrom(event))
        .listen((event) {
      callback(event['id']);
    });
  });
}
