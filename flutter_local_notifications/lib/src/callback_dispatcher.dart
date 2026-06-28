import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

DateTime? _dateTimeFromMillisecondsSinceEpoch(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  if (value is String) {
    final millisecondsSinceEpoch = int.tryParse(value);
    if (millisecondsSinceEpoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch,
        isUtc: true,
      );
    }
  }
  return null;
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  const EventChannel backgroundChannel = EventChannel(
    'dexterous.com/flutter/local_notifications/actions',
  );

  const MethodChannel channel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );

  channel.invokeMethod<int>('getCallbackHandle').then((int? handle) {
    final DidReceiveBackgroundNotificationResponseCallback? callback =
        handle == null
        ? null
        : PluginUtilities.getCallbackFromHandle(
                CallbackHandle.fromRawHandle(handle),
              )
              as DidReceiveBackgroundNotificationResponseCallback?;

    backgroundChannel
        .receiveBroadcastStream()
        .map<Map<dynamic, dynamic>>((dynamic event) => event)
        .map<Map<String, dynamic>>(
          (Map<dynamic, dynamic> event) => Map.castFrom(event),
        )
        .listen((Map<String, dynamic> event) {
          final Object notificationId = event['notificationId'];
          final int id;
          if (notificationId is int) {
            id = notificationId;
          } else if (notificationId is String) {
            id = int.parse(notificationId);
          } else {
            id = -1;
          }
          callback?.call(
            NotificationResponse(
              id: id,
              actionId: event['actionId'],
              input: event['input'],
              payload: event['payload'],
              notificationDeliveredAt: _dateTimeFromMillisecondsSinceEpoch(
                event['notificationDeliveredAt'],
              ),
              responseReceivedAt: _dateTimeFromMillisecondsSinceEpoch(
                event['responseReceivedAt'],
              ),
              notificationResponseType:
                  NotificationResponseType.selectedNotificationAction,
            ),
          );
        });
  });
}
