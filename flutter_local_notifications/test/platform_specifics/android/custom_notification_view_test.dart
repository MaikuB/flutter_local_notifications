import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomViewMapping', () {
    test('creates instance with required viewId', () {
      const mapping = CustomViewMapping(viewId: 'test_view');
      
      expect(mapping.viewId, 'test_view');
      expect(mapping.text, isNull);
      expect(mapping.actionId, isNull);
    });

    test('creates instance with text', () {
      const mapping = CustomViewMapping(
        viewId: 'test_view',
        text: 'Test Text',
      );
      
      expect(mapping.viewId, 'test_view');
      expect(mapping.text, 'Test Text');
      expect(mapping.actionId, isNull);
    });

    test('creates instance with actionId', () {
      const mapping = CustomViewMapping(
        viewId: 'test_view',
        actionId: 'test_action',
      );
      
      expect(mapping.viewId, 'test_view');
      expect(mapping.text, isNull);
      expect(mapping.actionId, 'test_action');
    });

    test('creates instance with both text and actionId', () {
      const mapping = CustomViewMapping(
        viewId: 'test_view',
        text: 'Test Text',
        actionId: 'test_action',
      );
      
      expect(mapping.viewId, 'test_view');
      expect(mapping.text, 'Test Text');
      expect(mapping.actionId, 'test_action');
    });

    test('toMap returns correct structure with only viewId', () {
      const mapping = CustomViewMapping(viewId: 'test_view');
      final map = mapping.toMap();
      
      expect(map, <String, dynamic>{
        'viewId': 'test_view',
      });
    });

    test('toMap returns correct structure with text', () {
      const mapping = CustomViewMapping(
        viewId: 'test_view',
        text: 'Test Text',
      );
      final map = mapping.toMap();
      
      expect(map, <String, dynamic>{
        'viewId': 'test_view',
        'text': 'Test Text',
      });
    });

    test('toMap returns correct structure with actionId', () {
      const mapping = CustomViewMapping(
        viewId: 'test_view',
        actionId: 'test_action',
      );
      final map = mapping.toMap();
      
      expect(map, <String, dynamic>{
        'viewId': 'test_view',
        'actionId': 'test_action',
      });
    });

    test('toMap returns correct structure with all fields', () {
      const mapping = CustomViewMapping(
        viewId: 'test_view',
        text: 'Test Text',
        actionId: 'test_action',
      );
      final map = mapping.toMap();
      
      expect(map, <String, dynamic>{
        'viewId': 'test_view',
        'text': 'Test Text',
        'actionId': 'test_action',
      });
    });

    test('toMap excludes null values', () {
      const mapping = CustomViewMapping(viewId: 'test_view');
      final map = mapping.toMap();
      
      expect(map.containsKey('text'), isFalse);
      expect(map.containsKey('actionId'), isFalse);
    });
  });

  group('CustomNotificationView', () {
    test('creates instance with required layoutName', () {
      const view = CustomNotificationView(layoutName: 'test_layout');
      
      expect(view.layoutName, 'test_layout');
      expect(view.viewMappings, isEmpty);
    });

    test('creates instance with empty viewMappings by default', () {
      const view = CustomNotificationView(layoutName: 'test_layout');
      
      expect(view.viewMappings, isA<List<CustomViewMapping>>());
      expect(view.viewMappings, isEmpty);
    });

    test('creates instance with viewMappings', () {
      const view = CustomNotificationView(
        layoutName: 'test_layout',
        viewMappings: [
          CustomViewMapping(viewId: 'view1', text: 'Text 1'),
          CustomViewMapping(viewId: 'view2', actionId: 'action2'),
        ],
      );
      
      expect(view.layoutName, 'test_layout');
      expect(view.viewMappings.length, 2);
      expect(view.viewMappings[0].viewId, 'view1');
      expect(view.viewMappings[1].viewId, 'view2');
    });

    test('toMap returns correct structure with empty mappings', () {
      const view = CustomNotificationView(layoutName: 'test_layout');
      final map = view.toMap();
      
      expect(map, <String, dynamic>{
        'layoutName': 'test_layout',
        'viewMappings': <Map<String, dynamic>>[],
      });
    });

    test('toMap returns correct structure with viewMappings', () {
      const view = CustomNotificationView(
        layoutName: 'test_layout',
        viewMappings: [
          CustomViewMapping(viewId: 'view1', text: 'Text 1'),
          CustomViewMapping(viewId: 'view2', actionId: 'action2'),
        ],
      );
      final map = view.toMap();
      
      expect(map, <String, dynamic>{
        'layoutName': 'test_layout',
        'viewMappings': [
          <String, dynamic>{'viewId': 'view1', 'text': 'Text 1'},
          <String, dynamic>{'viewId': 'view2', 'actionId': 'action2'},
        ],
      });
    });

    test('toMap correctly serializes complex viewMappings', () {
      const view = CustomNotificationView(
        layoutName: 'test_layout',
        viewMappings: [
          CustomViewMapping(
            viewId: 'view1',
            text: 'Text 1',
            actionId: 'action1',
          ),
          CustomViewMapping(viewId: 'view2'),
          CustomViewMapping(viewId: 'view3', text: 'Text 3'),
          CustomViewMapping(viewId: 'view4', actionId: 'action4'),
        ],
      );
      final map = view.toMap();
      
      expect(map['layoutName'], 'test_layout');
      expect(map['viewMappings'], isA<List>());
      expect((map['viewMappings'] as List).length, 4);
      
      final mappings = map['viewMappings'] as List<Map<String, dynamic>>;
      expect(mappings[0], containsPair('viewId', 'view1'));
      expect(mappings[0], containsPair('text', 'Text 1'));
      expect(mappings[0], containsPair('actionId', 'action1'));
      
      expect(mappings[1], containsPair('viewId', 'view2'));
      expect(mappings[1].containsKey('text'), isFalse);
      expect(mappings[1].containsKey('actionId'), isFalse);
    });
  });

  group('CustomNotificationView integration', () {
    test('can be used in AndroidNotificationDetails', () {
      const details = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
          viewMappings: [
            CustomViewMapping(viewId: 'title', text: 'Title'),
          ],
        ),
      );
      
      expect(details.customContentView, isNotNull);
      expect(details.customContentView!.layoutName, 'custom_layout');
      expect(details.customContentView!.viewMappings.length, 1);
    });

    test('supports all three custom view types', () {
      const details = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        customContentView: CustomNotificationView(
          layoutName: 'custom_layout',
        ),
        customBigContentView: CustomNotificationView(
          layoutName: 'custom_big_layout',
        ),
        customHeadsUpContentView: CustomNotificationView(
          layoutName: 'custom_headsup_layout',
        ),
      );
      
      expect(details.customContentView, isNotNull);
      expect(details.customBigContentView, isNotNull);
      expect(details.customHeadsUpContentView, isNotNull);
      
      expect(details.customContentView!.layoutName, 'custom_layout');
      expect(details.customBigContentView!.layoutName, 'custom_big_layout');
      expect(
        details.customHeadsUpContentView!.layoutName,
        'custom_headsup_layout',
      );
    });

    test('custom views can be null', () {
      const details = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
      );
      
      expect(details.customContentView, isNull);
      expect(details.customBigContentView, isNull);
      expect(details.customHeadsUpContentView, isNull);
    });
  });
}
