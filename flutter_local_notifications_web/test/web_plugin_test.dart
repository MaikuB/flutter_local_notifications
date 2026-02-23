@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_local_notifications_web/flutter_local_notifications_web.dart';
import 'package:flutter_local_notifications_web/src/handler.dart';
import 'package:flutter_local_notifications_web/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  group('StringUtils', () {
    test('nullIfEmpty returns null for empty string', () {
      expect(''.nullIfEmpty, isNull);
    });

    test('nullIfEmpty returns the string for non-empty string', () {
      expect('hello'.nullIfEmpty, equals('hello'));
    });

    test('nullIfEmpty returns single character string', () {
      expect(' '.nullIfEmpty, equals(' '));
    });
  });

  group('NullableWebNotificationDetailsUtils.toJs', () {
    test('converts null details with defaults', () {
      const WebNotificationDetails? details = null;
      final web.NotificationOptions options =
          details.toJs(1, 'body', 'payload');

      expect(options.tag, equals('1'));
      expect(options.body, equals('body'));
      expect(options.dir, equals('auto'));
      expect(options.badge, equals(''));
      expect(options.icon, equals(''));
      expect(options.image, equals(''));
      expect(options.lang, equals(''));
      expect(options.renotify, isFalse);
      expect(options.requireInteraction, isFalse);
    });

    test('stores notification id as tag', () {
      const WebNotificationDetails? details = null;
      final web.NotificationOptions options =
          details.toJs(42, 'body', 'payload');

      expect(options.tag, equals('42'));
    });

    test('stores payload in data object', () {
      const WebNotificationDetails? details = null;
      final web.NotificationOptions options =
          details.toJs(1, 'body', 'my-payload');

      final JSObject data = options.data! as JSObject;
      final String payload = (data['payload']! as JSString).toDart;
      expect(payload, equals('my-payload'));
    });

    test('handles null body', () {
      const WebNotificationDetails? details = null;
      final web.NotificationOptions options = details.toJs(1, null, null);

      expect(options.body, equals(''));
    });

    test('handles null payload in data', () {
      const WebNotificationDetails? details = null;
      final web.NotificationOptions options = details.toJs(1, 'body', null);

      final JSObject data = options.data! as JSObject;
      expect(data['payload'], isNull);
    });

    test('converts details with custom direction', () {
      const WebNotificationDetails details = WebNotificationDetails(
        direction: WebNotificationDirection.rightToLeft,
      );
      final web.NotificationOptions options = details.toJs(1, 'body', null);

      expect(options.dir, equals('rtl'));
    });

    test('converts details with URLs', () {
      final WebNotificationDetails details = WebNotificationDetails(
        badgeUrl: Uri.parse('https://example.com/badge.png'),
        iconUrl: Uri.parse('https://example.com/icon.png'),
        imageUrl: Uri.parse('https://example.com/image.png'),
      );
      final web.NotificationOptions options = details.toJs(1, 'body', null);

      expect(options.badge, equals('https://example.com/badge.png'));
      expect(options.icon, equals('https://example.com/icon.png'));
      expect(options.image, equals('https://example.com/image.png'));
    });

    test('converts details with language', () {
      const WebNotificationDetails details = WebNotificationDetails(
        lang: 'fr-FR',
      );
      final web.NotificationOptions options = details.toJs(1, 'body', null);

      expect(options.lang, equals('fr-FR'));
    });

    test('converts details with boolean flags', () {
      const WebNotificationDetails details = WebNotificationDetails(
        renotify: true,
        requireInteraction: true,
        isSilent: true,
      );
      final web.NotificationOptions options = details.toJs(1, 'body', null);

      expect(options.renotify, isTrue);
      expect(options.requireInteraction, isTrue);
      expect(options.silent, isTrue);
    });

    test('converts details with timestamp', () {
      final DateTime timestamp = DateTime(2024, 6, 15, 12, 30);
      final WebNotificationDetails details = WebNotificationDetails(
        timestamp: timestamp,
      );
      final web.NotificationOptions options = details.toJs(1, 'body', null);

      expect(options.timestamp, equals(timestamp.millisecondsSinceEpoch));
    });

    test('converts details with actions', () {
      final WebNotificationDetails details = WebNotificationDetails(
        actions: <WebNotificationAction>[
          const WebNotificationAction(action: 'reply', title: 'Reply'),
          WebNotificationAction(
            action: 'view',
            title: 'View',
            icon: Uri.parse('https://example.com/view.png'),
          ),
        ],
      );
      final web.NotificationOptions options = details.toJs(1, 'body', null);
      final List<web.NotificationAction> actions = options.actions.toDart;

      expect(actions.length, equals(2));
      expect(actions[0].action, equals('reply'));
      expect(actions[0].title, equals('Reply'));
      expect(actions[1].action, equals('view'));
      expect(actions[1].title, equals('View'));
      expect(actions[1].icon, equals('https://example.com/view.png'));
    });
  });

  group('JSNotificationData', () {
    test('creates NotificationResponse for notification click', () {
      final JSObject obj = JSObject();
      obj['id'] = '42'.toJS;
      obj['payload'] = 'test-payload'.toJS;
      final JSNotificationData data = obj as JSNotificationData;

      final NotificationResponse response = data.response;

      expect(response.id, equals(42));
      expect(response.payload, equals('test-payload'));
      expect(response.notificationResponseType,
          equals(NotificationResponseType.selectedNotification));
      expect(response.actionId, isNull);
      expect(response.input, isNull);
    });

    test('creates NotificationResponse for action click', () {
      final JSObject obj = JSObject();
      obj['id'] = '7'.toJS;
      obj['action'] = 'reply'.toJS;
      obj['payload'] = 'msg-payload'.toJS;
      obj['reply'] = 'user input'.toJS;
      final JSNotificationData data = obj as JSNotificationData;

      final NotificationResponse response = data.response;

      expect(response.id, equals(7));
      expect(response.payload, equals('msg-payload'));
      expect(response.actionId, equals('reply'));
      expect(response.input, equals('user input'));
      expect(response.notificationResponseType,
          equals(NotificationResponseType.selectedNotificationAction));
    });

    test('handles null payload and action', () {
      final JSObject obj = JSObject();
      obj['id'] = '1'.toJS;
      final JSNotificationData data = obj as JSNotificationData;

      final NotificationResponse response = data.response;

      expect(response.id, equals(1));
      expect(response.payload, isNull);
      expect(response.actionId, isNull);
      expect(response.input, isNull);
      expect(response.notificationResponseType,
          equals(NotificationResponseType.selectedNotification));
    });

    test('handles empty action as notification click', () {
      final JSObject obj = JSObject();
      obj['id'] = '1'.toJS;
      obj['action'] = ''.toJS;
      final JSNotificationData data = obj as JSNotificationData;

      final NotificationResponse response = data.response;

      expect(response.notificationResponseType,
          equals(NotificationResponseType.selectedNotification));
      expect(response.actionId, isNull);
    });

    test('handles empty payload', () {
      final JSObject obj = JSObject();
      obj['id'] = '1'.toJS;
      obj['payload'] = ''.toJS;
      final JSNotificationData data = obj as JSNotificationData;

      final NotificationResponse response = data.response;

      expect(response.payload, isNull);
    });

    test('handles non-numeric id', () {
      final JSObject obj = JSObject();
      obj['id'] = 'not-a-number'.toJS;
      final JSNotificationData data = obj as JSNotificationData;

      final NotificationResponse response = data.response;

      expect(response.id, isNull);
    });
  });

  group('JSNotificationUtils', () {
    test('id parses tag as integer', () {
      // Notification constructor requires a title; tag is set via options
      final web.Notification notification = web.Notification(
        'Test',
        web.NotificationOptions(tag: '42'),
      );
      expect(notification.id, equals(42));
    });

    test('id returns null for non-numeric tag', () {
      final web.Notification notification = web.Notification(
        'Test',
        web.NotificationOptions(tag: 'not-a-number'),
      );
      expect(notification.id, isNull);
    });

    test('id returns null for empty tag', () {
      final web.Notification notification = web.Notification(
        'Test',
      );
      expect(notification.id, isNull);
    });
  });
}
