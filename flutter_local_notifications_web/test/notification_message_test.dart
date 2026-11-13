@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_local_notifications_web/src/plugin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  final web.ServiceWorkerContainer worker = web.window.navigator.serviceWorker;
  late JSAny? originalNotification;
  late bool hadNotification;
  late JSAny? originalRegister;
  late JSAny? originalHandler;
  late WebFlutterLocalNotificationsPlugin? originalInstance;
  late List<NotificationResponse> responses;

  setUp(() async {
    hadNotification = globalContext.hasProperty('Notification'.toJS).toDart;
    originalNotification = globalContext['Notification'];
    globalContext['Notification'] = JSObject();
    originalRegister = worker['register'];
    originalHandler = worker['onmessage'];
    originalInstance = WebFlutterLocalNotificationsPlugin.instance;
    responses = <NotificationResponse>[];
    worker['register'] = ((JSString scriptURL) => Future<JSObject>.value(
      JSObject(),
    ).toJS).toJS;
    final WebFlutterLocalNotificationsPlugin plugin =
        WebFlutterLocalNotificationsPlugin();
    expect(
      await plugin.initialize(onDidReceiveNotificationResponse: responses.add),
      isTrue,
    );
  });

  tearDown(() {
    if (hadNotification) {
      globalContext['Notification'] = originalNotification;
    } else {
      globalContext.delete('Notification'.toJS);
    }
    worker['register'] = originalRegister;
    worker['onmessage'] = originalHandler;
    WebFlutterLocalNotificationsPlugin.instance = originalInstance;
  });

  void handle(Object? data) {
    worker.onmessage!.callAsFunction(
      worker,
      web.MessageEvent('message', web.MessageEventInit(data: data.jsify())),
    );
  }

  test('ignores unrelated service worker messages without an id', () {
    handle(<String, Object?>{'type': 'unrelated-message'});
    expect(responses, isEmpty);
  });

  test('leaves unrelated messages available to other listeners', () {
    int received = 0;
    final JSFunction listener = ((web.Event event) {
      received++;
    }).toJS;
    worker.addEventListener('message', listener);
    addTearDown(() => worker.removeEventListener('message', listener));

    worker.dispatchEvent(
      web.MessageEvent(
        'message',
        web.MessageEventInit(data: <String, Object?>{'type': 'other'}.jsify()),
      ),
    );

    expect(received, 1);
    expect(responses, isEmpty);
  });

  test('ignores null, primitive and array messages', () {
    for (final Object? data in <Object?>[
      null,
      'message',
      42,
      true,
      <Object>[],
    ]) {
      handle(data);
    }
    expect(responses, isEmpty);
  });

  test('ignores null or non-string ids', () {
    for (final Object? id in <Object?>[null, 42, true, <String, Object>{}]) {
      handle(<String, Object?>{'id': id});
    }
    expect(responses, isEmpty);
  });

  test('ignores non-string optional fields', () {
    for (final String field in <String>['action', 'payload', 'reply']) {
      for (final Object value in <Object>[42, true, <String, Object>{}]) {
        handle(<String, Object?>{'id': '42', field: value});
      }
    }
    expect(responses, isEmpty);
  });

  test('preserves clicks before and after an unrelated message', () {
    handle(<String, Object?>{'id': '42', 'payload': 'control'});
    handle(<String, Object?>{'type': 'unrelated-message'});
    handle(<String, Object?>{
      'id': '7',
      'action': 'reply',
      'payload': 'message',
      'reply': 'answer',
    });
    expect(responses, hasLength(2));
    expect(responses.first.id, 42);
    expect(responses.first.payload, 'control');
    expect(
      responses.first.notificationResponseType,
      NotificationResponseType.selectedNotification,
    );
    expect(responses.last.id, 7);
    expect(responses.last.actionId, 'reply');
    expect(responses.last.payload, 'message');
    expect(responses.last.input, 'answer');
    expect(
      responses.last.notificationResponseType,
      NotificationResponseType.selectedNotificationAction,
    );
  });

  test(
    'preserves null and empty optional fields and non-numeric string ids',
    () {
      handle(<String, Object?>{
        'id': '1',
        'action': null,
        'payload': null,
        'reply': null,
      });
      handle(<String, Object?>{
        'id': 'not-a-number',
        'action': '',
        'payload': '',
        'reply': '',
      });
      expect(responses, hasLength(2));
      expect(responses.first.id, 1);
      expect(responses.last.id, isNull);
      for (final NotificationResponse response in responses) {
        expect(response.actionId, isNull);
        expect(response.payload, isNull);
        expect(response.input, isNull);
        expect(
          response.notificationResponseType,
          NotificationResponseType.selectedNotification,
        );
      }
    },
  );
}
