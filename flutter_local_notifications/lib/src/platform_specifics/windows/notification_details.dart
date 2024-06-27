import 'package:xml/xml.dart';

import 'notification_action.dart';
import 'notification_audio.dart';
import 'notification_group.dart';
import 'notification_header.dart';
import 'notification_image.dart';
import 'notification_input.dart';
import 'notification_progress.dart';

export 'notification_part.dart';
export 'notification_text.dart';

/// The duration for a Windows notification.
enum WindowsNotificationDuration {
  /// The notification will stay for a long time.
  long,
  /// The notification will stay for a short time.
  short,
}

/// The scenario a notification is being used for.
enum WindowsNotificationScenario {
  /// Reminders are expanded and remain until manually dismissed.
  ///
  /// This will be ignored unless the notification also has at least one
  /// [WindowsAction] that activates a background task.
  reminder,

  /// Alarms are expanded and remain until manually dismissed.
  ///
  /// By default, alarm notifications loop the standard "alarm" sound.
  alarm,

  /// Calls are expanded and show in a special format.
  ///
  /// By default, call notifications loop the standard "call" sound.
  incomingCall,

  /// Urgent notifications can break through Do Not Disturb settings.
  urgent,
}

extension on DateTime {
  String toIso8601StringTz() {
    // Get offset
    final Duration offset = timeZoneOffset;
    final String sign = offset.isNegative ? '-' : '+';
    final String hours = offset.inHours.abs().toString().padLeft(2, '0');
    final String minutes = offset.inMinutes.abs().remainder(60)
      .toString().padLeft(2, '0');
    final String offsetString = '$sign$hours:$minutes';

    // Get first part of properly formatted ISO 8601 date
    final String formattedDate = toIso8601String().split('.').first;

    return '$formattedDate$offsetString';
  }
}

/// Contains notification details specific to Windows.
///
/// See: https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/adaptive-interactive-toasts
class WindowsNotificationDetails {
  /// Creates a Windows notification from the given options.
  WindowsNotificationDetails({
    this.actions = const <WindowsAction>[],
    this.inputs = const <WindowsInput>[],
    this.images = const <WindowsImage>[],
    this.groups = const <WindowsGroup>[],
    this.progressBars = const <WindowsProgressBar>[],
    this.header,
    this.audio,
    this.duration,
    this.scenario,
    this.timestamp,
    this.subtitle,
  }) : rawXml = null {
    if (actions.length > 5) {
      throw ArgumentError(
        'WindowsNotificationDetails can only have up to 5 actions',
      );
    }
    if (inputs.length > 5) {
      throw ArgumentError(
        'WindowsNotificationDetails can only have up to 5 inputs',
      );
    }
  }

  /// The raw XML passed to the Windows API.
  ///
  /// See https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/schema-root.
  /// For validation, see [the Windows Notifications Visualizer](https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/notifications-visualizer).
  final String? rawXml;

  /// A list of at most five action buttons.
  final List<WindowsAction> actions;

  /// A list of at most five input elements.
  final List<WindowsInput> inputs;

  /// A custom audio to play during this notification.
  final WindowsNotificationAudio? audio;

  /// The duration for this notification.
  final WindowsNotificationDuration? duration;

  /// The scenario for this notification. Sets some defaults based on the value.
  final WindowsNotificationScenario? scenario;

  /// The header for this group of notifications.
  final WindowsHeader? header;

  /// Overrides the timestamp to show on the notification.
  final DateTime? timestamp;

  /// A third line to show under the notification body.
  final String? subtitle;

  /// A list of images to show.
  final List<WindowsImage> images;

  /// A list of groups to show.
  final List<WindowsGroup> groups;

  /// A list of progress bars to show.
  final List<WindowsProgressBar> progressBars;

  /// XML attributes for the toast notification as a whole.
  Map<String, String> get attributes => <String, String>{
    if (duration != null) 'duration': duration!.name,
    if (timestamp != null) 'displayTimestamp': timestamp!.toIso8601StringTz(),
    if (scenario != null) 'scenario': scenario!.name,
  };

  /// Builds all relevant XML parts under the root `<toast>` element.
  void toXml(XmlBuilder builder) {
    if (rawXml != null) {
      builder.xml(rawXml!);
      return;
    }
    builder.element('actions', nest: () {
      for (final WindowsInput input in inputs) {
        input.toXml(builder);
      }
      for (final WindowsAction action in actions) {
        action.toXml(builder);
      }
    });
    audio?.toXml(builder);
    header?.toXml(builder);
  }

  /// Generates the `<binding>` element of the notification.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-binding
  void generateBinding(XmlBuilder builder) {
    if (subtitle != null) {
      builder.element('text', nest: subtitle);
    }
    for (final WindowsImage image in images) {
      image.toXml(builder);
    }
    for (final WindowsGroup group in groups) {
      group.toXml(builder);
    }
    for (final WindowsProgressBar progressBar in progressBars) {
      progressBar.toXml(builder);
    }
  }
}