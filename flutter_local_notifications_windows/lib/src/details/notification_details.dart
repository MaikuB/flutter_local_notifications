import 'notification_action.dart';
import 'notification_audio.dart';
import 'notification_header.dart';
import 'notification_input.dart';
import 'notification_parts.dart';
import 'notification_progress.dart';
import 'notification_row.dart';

export 'notification_parts.dart';

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

/// Contains notification details specific to Windows.
///
/// See: https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/adaptive-interactive-toasts
class WindowsNotificationDetails {
  /// Creates a Windows notification from the given options.
  const WindowsNotificationDetails({
    this.actions = const <WindowsAction>[],
    this.inputs = const <WindowsInput>[],
    this.images = const <WindowsImage>[],
    this.rows = const <WindowsRow>[],
    this.progressBars = const <WindowsProgressBar>[],
    this.bindings = const <String, String>{},
    this.header,
    this.audio,
    this.duration,
    this.scenario,
    this.timestamp,
    this.subtitle,
  });

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

  /// A list of rows to show.
  final List<WindowsRow> rows;

  /// A list of progress bars to show.
  final List<WindowsProgressBar> progressBars;

  /// Custom bindings in the notification.
  ///
  /// Text elements can contains "bindings", which are entered as
  /// `{bindingName}` directly into the string values. You can then update them
  /// while or after the notification is launched by using the binding name as
  /// the key here, and the value as any string you want.
  final Map<String, String> bindings;
}
