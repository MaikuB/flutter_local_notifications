import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_local_notifications_web/flutter_local_notifications_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebNotificationDetails', () {
    test('creates with default values', () {
      const WebNotificationDetails details = WebNotificationDetails();

      expect(details.actions, isEmpty);
      expect(details.direction, equals(WebNotificationDirection.auto));
      expect(details.requireInteraction, isFalse);
      expect(details.isSilent, isFalse);
      expect(details.renotify, isFalse);
      expect(details.badgeUrl, isNull);
      expect(details.iconUrl, isNull);
      expect(details.imageUrl, isNull);
      expect(details.lang, isNull);
      expect(details.timestamp, isNull);
      expect(details.timestamp, isNull);
    });

    test('creates with custom values', () {
      final Uri badgeUrl = Uri.parse('https://example.com/badge.png');
      final Uri iconUrl = Uri.parse('https://example.com/icon.png');
      final Uri imageUrl = Uri.parse('https://example.com/image.png');
      final DateTime timestamp = DateTime(2024, 1, 1);

      final WebNotificationDetails details = WebNotificationDetails(
        actions: const <WebNotificationAction>[
          WebNotificationAction(action: 'test', title: 'Test'),
        ],
        direction: WebNotificationDirection.leftToRight,
        badgeUrl: badgeUrl,
        iconUrl: iconUrl,
        imageUrl: imageUrl,
        lang: 'en-US',
        requireInteraction: true,
        isSilent: true,
        renotify: true,
        timestamp: timestamp,
      );

      expect(details.actions.length, equals(1));
      expect(details.direction, equals(WebNotificationDirection.leftToRight));
      expect(details.badgeUrl, equals(badgeUrl));
      expect(details.iconUrl, equals(iconUrl));
      expect(details.imageUrl, equals(imageUrl));
      expect(details.lang, equals('en-US'));
      expect(details.requireInteraction, isTrue);
      expect(details.isSilent, isTrue);
      expect(details.renotify, isTrue);
      expect(details.timestamp, equals(timestamp));
      expect(details.timestamp, equals(timestamp));
    });

    test('creates with multiple actions', () {
      const WebNotificationDetails details = WebNotificationDetails(
        actions: <WebNotificationAction>[
          WebNotificationAction(action: 'reply', title: 'Reply'),
          WebNotificationAction(action: 'dismiss', title: 'Dismiss'),
          WebNotificationAction(action: 'archive', title: 'Archive'),
        ],
      );

      expect(details.actions.length, equals(3));
      expect(details.actions[0].action, equals('reply'));
      expect(details.actions[1].action, equals('dismiss'));
      expect(details.actions[2].action, equals('archive'));
    });

    test('creates with silent notification', () {
      const WebNotificationDetails details = WebNotificationDetails(
        isSilent: true,
      );

      expect(details.isSilent, isTrue);
      expect(details.isSilent, isTrue);
    });

    test('creates with require interaction', () {
      const WebNotificationDetails details = WebNotificationDetails(
        requireInteraction: true,
      );

      expect(details.requireInteraction, isTrue);
    });

    test('creates with renotify', () {
      const WebNotificationDetails details = WebNotificationDetails(
        renotify: true,
      );

      expect(details.renotify, isTrue);
    });

    test('creates with language code', () {
      const WebNotificationDetails details = WebNotificationDetails(
        lang: 'fr-FR',
      );

      expect(details.lang, equals('fr-FR'));
    });

    test('creates with all URL types', () {
      final Uri badgeUrl = Uri.parse('https://example.com/badge.png');
      final Uri iconUrl = Uri.parse('https://example.com/icon.png');
      final Uri imageUrl = Uri.parse('https://example.com/image.png');

      final WebNotificationDetails details = WebNotificationDetails(
        badgeUrl: badgeUrl,
        iconUrl: iconUrl,
        imageUrl: imageUrl,
      );

      expect(details.badgeUrl, equals(badgeUrl));
      expect(details.iconUrl, equals(iconUrl));
      expect(details.imageUrl, equals(imageUrl));
    });
  });

  group('WebNotificationAction', () {
    test('creates with required fields', () {
      const WebNotificationAction action = WebNotificationAction(
        action: 'reply',
        title: 'Reply',
      );

      expect(action.action, equals('reply'));
      expect(action.title, equals('Reply'));
      expect(action.icon, isNull);
    });

    test('creates with icon', () {
      final Uri iconUrl = Uri.parse('https://example.com/reply.png');
      final WebNotificationAction action = WebNotificationAction(
        action: 'reply',
        title: 'Reply',
        icon: iconUrl,
      );

      expect(action.action, equals('reply'));
      expect(action.title, equals('Reply'));
      expect(action.icon, equals(iconUrl));
    });

    test('creates multiple actions with different properties', () {
      final Uri icon1 = Uri.parse('https://example.com/icon1.png');
      final Uri icon2 = Uri.parse('https://example.com/icon2.png');

      final WebNotificationAction action1 = WebNotificationAction(
        action: 'action1',
        title: 'Action 1',
        icon: icon1,
      );

      const WebNotificationAction action2 = WebNotificationAction(
        action: 'action2',
        title: 'Action 2',
      );

      final WebNotificationAction action3 = WebNotificationAction(
        action: 'action3',
        title: 'Action 3',
        icon: icon2,
      );

      expect(action1.action, equals('action1'));
      expect(action1.icon, equals(icon1));
      expect(action2.action, equals('action2'));
      expect(action2.icon, isNull);
      expect(action3.action, equals('action3'));
      expect(action3.icon, equals(icon2));
    });
  });

  group('WebNotificationDirection', () {
    test('has correct jsValue for auto', () {
      expect(WebNotificationDirection.auto.jsValue, equals('auto'));
    });

    test('has correct jsValue for leftToRight', () {
      expect(WebNotificationDirection.leftToRight.jsValue, equals('ltr'));
    });

    test('has correct jsValue for rightToLeft', () {
      expect(WebNotificationDirection.rightToLeft.jsValue, equals('rtl'));
    });

    test('all enum values are unique', () {
      final Set<String> values = <String>{
        WebNotificationDirection.auto.jsValue,
        WebNotificationDirection.leftToRight.jsValue,
        WebNotificationDirection.rightToLeft.jsValue,
      };

      expect(values.length, equals(3));
    });
  });

  group('WebInitializationSettings', () {
    test('can be created with const constructor', () {
      const WebInitializationSettings settings = WebInitializationSettings();
      expect(settings, isNotNull);
    });
  });

  group('WebFlutterLocalNotificationsPlugin', () {
    late WebFlutterLocalNotificationsPlugin plugin;

    setUp(() async {
      plugin = WebFlutterLocalNotificationsPlugin();
      await plugin.initialize();
    });

    test('extends platform interface', () {
      expect(plugin, isA<FlutterLocalNotificationsPlatform>());
    });

    test('pendingNotificationRequests returns empty list', () async {
      final List<PendingNotificationRequest> requests =
          await plugin.pendingNotificationRequests();

      expect(requests, isEmpty);
    });

    test('periodicallyShow throws UnsupportedError', () {
      expect(
        () => plugin.periodicallyShow(
          id: 1,
          title: 'Test',
          body: 'Test',
          repeatInterval: RepeatInterval.hourly,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('periodicallyShowWithDuration throws UnsupportedError', () {
      expect(
        () => plugin.periodicallyShowWithDuration(
          id: 1,
          title: 'Test',
          body: 'Test',
          repeatDurationInterval: const Duration(minutes: 5),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('cancel completes with no active notifications', () async {
      await expectLater(plugin.cancel(id: 1), completes);
    });

    test('cancelAll completes with no active notifications', () async {
      await expectLater(plugin.cancelAll(), completes);
    });

    test('getActiveNotifications returns empty with no notifications',
        () async {
      final List<ActiveNotification> notifications =
          await plugin.getActiveNotifications();

      expect(notifications, isEmpty);
    });

    test('getNotificationAppLaunchDetails returns null without launch params',
        () async {
      final NotificationAppLaunchDetails? details =
          await plugin.getNotificationAppLaunchDetails();

      expect(details, isNull);
    });
  });
}
