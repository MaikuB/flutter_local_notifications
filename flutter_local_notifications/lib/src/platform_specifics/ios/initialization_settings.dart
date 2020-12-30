import 'package:flutter/foundation.dart';

import '../../typedefs.dart';
import 'enums.dart';

/// Describes the notification action type.
///
/// This type is used internally.
enum _IOSNotificationActionType {
  /// Corresponds to the `UNNotificationAction` type defined at
  /// https://developer.apple.com/documentation/usernotifications/unnotificationaction
  plain,

  /// Corresponds to the `UNTextInputNotificationAction` type defined at
  /// https://developer.apple.com/documentation/usernotifications/untextinputnotificationaction
  text,
}

/// Describes the notification action itself.
///
/// See the official docs at
/// https://developer.apple.com/documentation/usernotifications/unnotificationaction
/// for more details.
class IOSNotificationAction {
  /// Creates a `UNNotificationAction` for simple actions
  factory IOSNotificationAction.plain(
    String identifier,
    String title, {
    Set<IOSNotificationActionOption> options =
        const <IOSNotificationActionOption>{},
  }) =>
      IOSNotificationAction._(
        _IOSNotificationActionType.plain,
        identifier,
        title,
        options: options,
      );

  /// Creates a `UNTextInputNotificationAction` to collect user defined input.
  factory IOSNotificationAction.text(
    String identifier,
    String title, {
    @required String buttonTitle,
    String placeholder,
    Set<IOSNotificationActionOption> options =
        const <IOSNotificationActionOption>{},
  }) =>
      IOSNotificationAction._(
        _IOSNotificationActionType.text,
        identifier,
        title,
        buttonTitle: buttonTitle,
        placeholder: placeholder,
        options: options,
      );

  const IOSNotificationAction._(
    this.type,
    this.identifier,
    this.title, {
    this.options = const <IOSNotificationActionOption>{},
    this.buttonTitle,
    this.placeholder,
  });

  /// Notification Action type.
  final _IOSNotificationActionType type;

  /// The unique string that your app uses to identify the action.
  final String identifier;

  /// The localized string to use as the title of the action.
  final String title;

  /// The behaviors associated with the action.
  ///
  /// See [IOSNotificationActionOption] for available options.
  final Set<IOSNotificationActionOption> options;

  /// The localized title of the text input button that is displayed to the
  /// user.
  final String buttonTitle;

  /// The localized placeholder text to display in the text input field.
  final String placeholder;
}

/// Corresponds to the `UNNotificationCategory` type which is used to configure
/// notification categories and accompanying options.
///
/// See the official docs at
/// https://developer.apple.com/documentation/usernotifications/unnotificationcategory
/// for more details.
class IOSNotificationCategory {
  /// Constructs a instance of [IOSNotificationCategory].
  const IOSNotificationCategory(
    this.identifier, {
    this.actions = const <IOSNotificationAction>[],
    this.options = const <IOSNotificationCategoryOption>{},
  });

  /// The unique string assigned to the category.
  final String identifier;

  /// The actions to display when a notification of this type is presented.
  final List<IOSNotificationAction> actions;

  /// Options for how to handle notifications of this type.
  final Set<IOSNotificationCategoryOption> options;
}

/// Plugin initialization settings for iOS.
class IOSInitializationSettings {
  /// Constructs an instance of [IOSInitializationSettings].
  const IOSInitializationSettings({
    this.requestAlertPermission = true,
    this.requestSoundPermission = true,
    this.requestBadgePermission = true,
    this.defaultPresentAlert = true,
    this.defaultPresentSound = true,
    this.defaultPresentBadge = true,
    this.onDidReceiveLocalNotification,
    this.notificationCategories = const <IOSNotificationCategory>[],
  })  : assert(requestAlertPermission != null),
        assert(requestSoundPermission != null),
        assert(requestBadgePermission != null),
        assert(defaultPresentAlert != null),
        assert(defaultPresentBadge != null),
        assert(defaultPresentSound != null);

  /// Request permission to display an alert.
  ///
  /// Default value is true.
  final bool requestAlertPermission;

  /// Request permission to play a sound.
  ///
  /// Default value is true.
  final bool requestSoundPermission;

  /// Request permission to badge app icon.
  ///
  /// Default value is true.
  final bool requestBadgePermission;

  /// Configures the default setting on if an alert should be displayed when a
  /// notification is triggered while app is in the foreground.
  ///
  /// Default value is true.
  ///
  /// This property is only applicable to iOS 10 or newer.

  final bool defaultPresentAlert;

  /// Configures the default setting on if a sound should be played when a
  /// notification is triggered while app is in the foreground by default.
  ///
  /// Default value is true.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool defaultPresentSound;

  /// Configures the default setting on if a badge value should be applied when
  /// a notification is triggered while app is in the foreground by default.
  ///
  /// Default value is true.
  ///
  /// This property is only applicable to iOS 10 or newer.
  final bool defaultPresentBadge;

  /// Callback for handling when a notification is triggered while the app is
  /// in the foreground.
  ///
  /// This property is only applicable to iOS versions older than 10.
  final DidReceiveLocalNotificationCallback onDidReceiveLocalNotification;

  /// Configure the notification categories ([IOSNotificationCategory])
  /// available. This allows for fine-tuning of preview display.
  ///
  /// Notification actions are configured in each [IOSNotificationCategory].
  final List<IOSNotificationCategory> notificationCategories;
}
