import 'package:flutter/foundation.dart';

import '../../typedefs.dart';

enum IOSNotificationActionType {
  plain,
  text,
}

enum IOSNotificationActionOption {
  authenticationRequired,
  destructive,
  foreground,
}

class IOSNotificationAction {
  factory IOSNotificationAction.plain(
    String identifier,
    String title, {
    Set<IOSNotificationActionOption> options =
        const <IOSNotificationActionOption>{},
  }) =>
      IOSNotificationAction._(
        IOSNotificationActionType.plain,
        identifier,
        title,
        options: options,
      );

  factory IOSNotificationAction.text(
    String identifier,
    String title, {
    @required String buttonTitle,
    String placeholder,
    Set<IOSNotificationActionOption> options =
        const <IOSNotificationActionOption>{},
  }) =>
      IOSNotificationAction._(
        IOSNotificationActionType.text,
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
    this.buttonTitle = '',
    this.placeholder = '',
  });

  final IOSNotificationActionType type;
  final String identifier;
  final String title;
  final Set<IOSNotificationActionOption> options;
  final String buttonTitle;
  final String placeholder;
}

enum IOSNotificationCategoryOption {
  customDismissAction,
  allowInCarPlay,
  hiddenPreviewShowTitle,
  hiddenPreviewShowSubtitle,
  allowAnnouncement,
}

class IOSNotificationCategory {
  const IOSNotificationCategory(
    this.identifier,
    this.actions, {
    this.options = const <IOSNotificationCategoryOption>{},
  });

  final String identifier;
  final List<IOSNotificationAction> actions;
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

  /// Configure the
  final List<IOSNotificationCategory> notificationCategories;
}
