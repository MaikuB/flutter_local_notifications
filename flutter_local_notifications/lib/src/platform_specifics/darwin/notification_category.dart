import 'notification_action.dart';
import 'notification_category_option.dart';

/// Corresponds to the `UNNotificationCategory` type which is used to configure
/// notification categories and accompanying options.
///
/// See the official docs at
/// https://developer.apple.com/documentation/usernotifications/unnotificationcategory
/// for more details.
class DarwinNotificationCategory {
  /// Constructs a instance of [DarwinNotificationCategory].
  const DarwinNotificationCategory(
    this.identifier, {
    this.actions = const <DarwinNotificationAction>[],
    this.options = const <DarwinNotificationCategoryOption>{},
  });

  /// The unique string assigned to the category.
  final String identifier;

  /// The actions to display when a notification of this type is presented.
  final List<DarwinNotificationAction> actions;

  /// Options for how to handle notifications of this type.
  final Set<DarwinNotificationCategoryOption> options;
}
