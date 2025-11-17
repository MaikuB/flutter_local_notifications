// ignore_for_file: always_specify_types

import 'package:flutter_local_notifications/src/platform_specifics/darwin/mappers.dart';
import 'package:flutter_local_notifications/src/platform_specifics/darwin/notification_action.dart';
import 'package:flutter_local_notifications/src/platform_specifics/darwin/notification_action_option.dart';
import 'package:flutter_local_notifications/src/platform_specifics/darwin/notification_category.dart';
import 'package:flutter_local_notifications/src/platform_specifics/darwin/notification_category_option.dart';
import 'package:flutter_local_notifications/src/platform_specifics/darwin/initialization_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DarwinNotificationActionMapper', () {
    test('should map fields and options correctly', () {
      expect(
        DarwinNotificationAction.plain('test_id', 'Something', options: {
          DarwinNotificationActionOption.authenticationRequired,
          DarwinNotificationActionOption.destructive,
          DarwinNotificationActionOption.foreground,
        }).toMap(),
        {
          'identifier': 'test_id',
          'title': 'Something',
          'options': [1, 2, 4],
          'type': 'plain',
        },
      );
    });
  });

  group('DarwinNotificationCategoryMapper', () {
    test('should map fields and options correctly', () {
      expect(
        const DarwinNotificationCategory('test_id', options: {
          DarwinNotificationCategoryOption.customDismissAction,
          DarwinNotificationCategoryOption.allowInCarPlay,
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          DarwinNotificationCategoryOption.hiddenPreviewShowSubtitle,
          DarwinNotificationCategoryOption.allowAnnouncement,
        }).toMap(),
        {
          'identifier': 'test_id',
          'actions': [],
          'options': [1, 2, 4, 8, 16],
        },
      );
    });
  });

  group('IOSInitializationSettingsMapper', () {
    test('should map CarPlay permission correctly', () {
      const iosSettings = IOSInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestCarPlayPermission: true,
        requestCriticalPermission: false,
        requestProvisionalPermission: false,
        requestProvidesAppNotificationSettings: false,
      );
      
      final map = iosSettings.toMap();
      
      expect(map['requestAlertPermission'], true);
      expect(map['requestSoundPermission'], true);
      expect(map['requestBadgePermission'], true);
      expect(map['requestCarPlayPermission'], true);
      expect(map['requestCriticalPermission'], false);
      expect(map['requestProvisionalPermission'], false);
      expect(map['requestProvidesAppNotificationSettings'], false);
    });
    
    test('should inherit Darwin settings and add CarPlay permission', () {
      const iosSettings = IOSInitializationSettings(
        requestCarPlayPermission: true,
      );
      
      final map = iosSettings.toMap();
      
      // Should have all Darwin defaults
      expect(map['requestAlertPermission'], true);
      expect(map['requestSoundPermission'], true);
      expect(map['requestBadgePermission'], true);
      expect(map['defaultPresentAlert'], true);
      expect(map['defaultPresentSound'], true);
      expect(map['defaultPresentBadge'], true);
      expect(map['defaultPresentBanner'], true);
      expect(map['defaultPresentList'], true);
      
      // Plus iOS-specific CarPlay
      expect(map['requestCarPlayPermission'], true);
    });
  });
}
