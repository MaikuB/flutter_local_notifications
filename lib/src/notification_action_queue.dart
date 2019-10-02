import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'notification_action_data.dart';

const _sharedPreferencesKey = "flutterLocalNotificationActionPayloads";

const _notificationPortName = "flutterLocalNotificationActionIsolate";

class NotificationActionQueue {
  NotificationActionQueue(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Stream<NotificationActionData> get onSelectAction =>
      _registerUpdateStream().asyncExpand((_) async* {
        while (true) {
          final data = await _getNextDataToProcess();
          if (data == null) break;
          yield data;
        }
      });

  Future<NotificationActionData> _getNextDataToProcess() async {
    await _sharedPreferences.reload();

    var dataJsonList = _sharedPreferences.getStringList(
        _sharedPreferencesKey) ?? [];
    print("Notification action data pieces to process: $dataJsonList");
    if (dataJsonList.isEmpty) return null;
    final nextJson = dataJsonList[0];

    dataJsonList = dataJsonList.sublist(1, dataJsonList.length);
    // FIXME: there's room for a race condition here if payloads have been modified from another isolate in the meantime
    await _sharedPreferences.setStringList(_sharedPreferencesKey, dataJsonList);

    final next = NotificationActionData.fromMap(json.decode(nextJson));

    return next;
  }

  Stream<void> _registerUpdateStream() async* {
    final receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping(_notificationPortName);
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, _notificationPortName);
    yield null; // look for previously saved payloads
    yield* receivePort;
  }

  Future<void> enqueueNotificationAction(NotificationActionData data) async {
    final dataJson = json.encode(data.toMap());

    print("Enqueuing notification action: $dataJson");

    await _sharedPreferences.reload();

    final dataJsonList =
        _sharedPreferences.getStringList(_sharedPreferencesKey) ?? [];
    dataJsonList.add(dataJson);
    // FIXME: there's room for a race condition here if payloads have been modified from another isolate in the meantime
    await _sharedPreferences.setStringList(_sharedPreferencesKey, dataJsonList);

    final sendPort = IsolateNameServer.lookupPortByName(_notificationPortName);
    sendPort?.send(null);
  }
}
