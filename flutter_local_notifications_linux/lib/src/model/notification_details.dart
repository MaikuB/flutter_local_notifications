import 'capabilities.dart';
import 'enums.dart';
import 'hint.dart';
import 'icon.dart';
import 'location.dart';
import 'sound.dart';
import 'timeout.dart';

/// Configures notification details specific to Linux.
/// The system may not support all features.
class LinuxNotificationDetails {
  /// Constructs an instance of [LinuxNotificationDetails].
  const LinuxNotificationDetails({
    this.icon,
    this.sound,
    this.category,
    this.urgency,
    this.timeout = const LinuxNotificationTimeout.systemDefault(),
    this.resident = false,
    this.suppressSound = false,
    this.transient = false,
    this.location,
    this.defaultActionName,
    this.customHints,
    this.actions = const <LinuxNotificationAction>[],
    this.actionKeyAsIconName = false,
  });

  /// Specifies the notification icon.
  final LinuxNotificationIcon? icon;

  /// Specifies the notification sound.
  /// Typical value is `ThemeLinuxSound('message')`
  final LinuxNotificationSound? sound;

  /// Specifies the category for notification.
  /// This can be used by the notification server to filter or
  /// display the data in a certain way.
  final LinuxNotificationCategory? category;

  /// Sets the urgency level for notification.
  final LinuxNotificationUrgency? urgency;

  /// Sets the timeout for notification.
  /// To set the default time, pass [LinuxNotificationTimeout.systemDefault]
  /// value. To set the notification to never expire,
  /// pass [LinuxNotificationTimeout.expiresNever].
  ///
  /// Note that the timeout may be ignored by the server.
  final LinuxNotificationTimeout timeout;

  /// When set the server will not automatically remove the notification
  /// when an action has been invoked. The notification will remain resident in
  /// the server until it is explicitly removed by the user or by the sender.
  /// This option is likely only useful when the server has
  /// the [LinuxServerCapabilities.persistence] capability.
  final bool resident;

  /// Causes the server to suppress playing any sounds, if it has that ability.
  /// This is usually set when the client itself is going to play its own sound.
  final bool suppressSound;

  /// When set the server will treat the notification as transient and
  /// by-pass the server's [LinuxServerCapabilities.persistence] capability,
  /// if it should exist.
  final bool transient;

  /// Specifies the location on the screen that the notification
  /// should point to.
  final LinuxNotificationLocation? location;

  /// Name of the default action (usually triggered by clicking
  /// the notification).
  /// The name can be anything, though implementations are free not to
  /// display it.
  final String? defaultActionName;

  /// Custom hints list to provide extra data to a notification server that
  /// the server may be able to make use of. Before using, make sure that
  /// the server supports this capability, please see [LinuxServerCapabilities].
  final List<LinuxNotificationCustomHint>? customHints;

  /// Specify a list of actions associated with this notifications.
  final List<LinuxNotificationAction> actions;

  /// If `true`, the server will attempt to interpret
  /// [LinuxNotificationAction.key] as a named icon.
  /// [LinuxNotificationAction.label] will be used to annotate the icon for
  /// accessibility purposes. The icon name should be compliant with the
  /// Freedesktop.org Icon Naming Specification https://specifications.freedesktop.org/icon-naming-spec/latest/
  ///
  /// Note: before using, make sure that the server supports this capability,
  /// please see [LinuxServerCapabilities].
  final bool actionKeyAsIconName;
}

/// Represents an action, that send a request message back to the notification
/// client when invoked. This functionality may not be implemented by the
/// notification server, conforming clients should check if it's available using
/// [LinuxServerCapabilities].
/// For more information, please see Desktop Notifications Specification https://specifications.freedesktop.org/notification-spec/latest/ar01s02.html
class LinuxNotificationAction {
  /// Constructs a [LinuxNotificationAction] object.
  const LinuxNotificationAction({
    required this.key,
    required this.label,
  });

  /// Unique ID for this action. This ID will be sent back in the action handler
  /// defined in [FlutterLocalNotificationsPlugin].
  ///
  /// If [LinuxNotificationDetails.keyAsIconName] is `true`,
  /// the server will attempt to interpret [key] as a named icon.
  /// [label] will be used to annotate the icon for accessibility purposes.
  /// The icon name should be compliant with the Freedesktop.org Icon Naming Specification https://specifications.freedesktop.org/icon-naming-spec/latest/
  final String key;

  /// Label to show to the user.
  final String label;
}
