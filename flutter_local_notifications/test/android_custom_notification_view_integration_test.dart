import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AndroidFlutterLocalNotificationsPlugin.registerWith();
  TestWidgetsFlutterBinding.ensureInitialized();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  group('Android Custom Notification View Integration', () {
    const MethodChannel channel = MethodChannel(
      'dexterous.com/flutter/local_notifications',
    );
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'initialize') {
          return true;
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return null;
        }
        return null;
      });
    });

    tearDown(() {
      log.clear();
    });

    test('show with customContentView serializes correctly', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'title', text: 'Custom Title'),
            CustomViewMapping(viewId: 'button', actionId: 'btn_action'),
          ],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: null,
        body: null,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );

      expect(log.last.method, 'show');
      final args = log.last.arguments as Map<String, Object?>;
      final platformSpecifics = args['platformSpecifics'] as Map<String, Object?>?;
      
      expect(platformSpecifics, isNotNull);
      expect(platformSpecifics!['customContentView'], isNotNull);
      
      final customView = platformSpecifics['customContentView'] as Map<String, Object?>;
      expect(customView['layoutName'], 'custom_layout');
      expect(customView['viewMappings'], isA<List>());
      
      final mappings = customView['viewMappings'] as List;
      expect(mappings.length, 2);
      expect(mappings[0]['viewId'], 'title');
      expect(mappings[0]['text'], 'Custom Title');
      expect(mappings[1]['viewId'], 'button');
      expect(mappings[1]['actionId'], 'btn_action');
    });

    test('show with customBigContentView serializes correctly', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
        ),
        customBigContentView: CustomNotificationView(
          layoutName: 'custom_big_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'description', text: 'Long description'),
          ],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: null,
        body: null,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );

      final args = log.last.arguments as Map<String, Object?>;
      final platformSpecifics = args['platformSpecifics'] as Map<String, Object?>?;
      
      expect(platformSpecifics!['customBigContentView'], isNotNull);
      
      final customBigView = platformSpecifics['customBigContentView'] as Map<String, Object?>;
      expect(customBigView['layoutName'], 'custom_big_layout');
      
      final mappings = customBigView['viewMappings'] as List;
      expect(mappings.length, 1);
      expect(mappings[0]['viewId'], 'description');
      expect(mappings[0]['text'], 'Long description');
    });

    test('show with customHeadsUpContentView serializes correctly', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
        ),
        customHeadsUpContentView: CustomNotificationView(
          layoutName: 'custom_headsup_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'headsup_title', text: 'Urgent!'),
            CustomViewMapping(viewId: 'headsup_button', actionId: 'urgent_action'),
          ],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: null,
        body: null,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );

      final args = log.last.arguments as Map<String, Object?>;
      final platformSpecifics = args['platformSpecifics'] as Map<String, Object?>?;
      
      expect(platformSpecifics!['customHeadsUpContentView'], isNotNull);
      
      final customHeadsUpView = platformSpecifics['customHeadsUpContentView'] as Map<String, Object?>;
      expect(customHeadsUpView['layoutName'], 'custom_headsup_layout');
      
      final mappings = customHeadsUpView['viewMappings'] as List;
      expect(mappings.length, 2);
      expect(mappings[0]['viewId'], 'headsup_title');
      expect(mappings[0]['text'], 'Urgent!');
      expect(mappings[1]['viewId'], 'headsup_button');
      expect(mappings[1]['actionId'], 'urgent_action');
    });

    test('show with all three custom views serializes correctly', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'title', text: 'Title'),
          ],
        ),
        customBigContentView: CustomNotificationView(
          layoutName: 'custom_big_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'description', text: 'Description'),
          ],
        ),
        customHeadsUpContentView: CustomNotificationView(
          layoutName: 'custom_headsup_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'headsup_title', text: 'Urgent'),
          ],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: null,
        body: null,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );

      final args = log.last.arguments as Map<String, Object?>;
      final platformSpecifics = args['platformSpecifics'] as Map<String, Object?>?;
      
      expect(platformSpecifics!['customContentView'], isNotNull);
      expect(platformSpecifics['customBigContentView'], isNotNull);
      expect(platformSpecifics['customHeadsUpContentView'], isNotNull);
    });

    test('show without custom views does not include them in serialization', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: 'Title',
        body: 'Body',
        notificationDetails: const NotificationDetails(android: androidDetails),
      );

      final args = log.last.arguments as Map<String, Object?>;
      final platformSpecifics = args['platformSpecifics'] as Map<String, Object?>?;
      
      expect(platformSpecifics!.containsKey('customContentView'), isFalse);
      expect(platformSpecifics.containsKey('customBigContentView'), isFalse);
      expect(platformSpecifics.containsKey('customHeadsUpContentView'), isFalse);
    });

    test('custom view with empty viewMappings serializes correctly', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: null,
        body: null,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );

      final args = log.last.arguments as Map<String, Object?>;
      final platformSpecifics = args['platformSpecifics'] as Map<String, Object?>?;
      final customView = platformSpecifics!['customContentView'] as Map<String, Object?>;
      
      expect(customView['layoutName'], 'custom_layout');
      expect(customView['viewMappings'], isA<List>());
      expect((customView['viewMappings'] as List).isEmpty, isTrue);
    });

    test('custom view with complex mappings serializes correctly', () async {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('app_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'view1', text: 'Text only'),
            CustomViewMapping(viewId: 'view2', actionId: 'Action only'),
            CustomViewMapping(
              viewId: 'view3',
              text: 'Both',
              actionId: 'both_action',
            ),
            CustomViewMapping(viewId: 'view4'),
          ],
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: null,
        body: null,
        notificationDetails: const NotificationDetails(android: androidDetails),
      );

      final args = log.last.arguments as Map<String, Object?>;
      final platformSpecifics = args['platformSpecifics'] as Map<String, Object?>?;
      final customView = platformSpecifics!['customContentView'] as Map<String, Object?>;
      final mappings = customView['viewMappings'] as List;
      
      expect(mappings.length, 4);
      
      // View with text only
      expect(mappings[0]['viewId'], 'view1');
      expect(mappings[0]['text'], 'Text only');
      expect(mappings[0].containsKey('actionId'), isFalse);
      
      // View with action only
      expect(mappings[1]['viewId'], 'view2');
      expect(mappings[1]['actionId'], 'Action only');
      expect(mappings[1].containsKey('text'), isFalse);
      
      // View with both
      expect(mappings[2]['viewId'], 'view3');
      expect(mappings[2]['text'], 'Both');
      expect(mappings[2]['actionId'], 'both_action');
      
      // View with neither
      expect(mappings[3]['viewId'], 'view4');
      expect(mappings[3].containsKey('text'), isFalse);
      expect(mappings[3].containsKey('actionId'), isFalse);
    });
  });
}
