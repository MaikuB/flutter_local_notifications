import '../../flutter_local_notifications_windows.dart';

/// A progress bar in a Windows notification.
///
/// To update the progress after the notification has been shown,
/// use [FlutterLocalNotificationsWindows.updateProgressBar].
class WindowsProgressBar {
  /// Creates a progress bar for a Windows notification.
  WindowsProgressBar({
    required this.id,
    required this.status,
    required this.value,
    this.title,
    this.label,
  });

  /// A unique ID for this progress bar.
  final String id;

  /// An optional title.
  final String? title;

  /// Describes what's happening, like `Downloading...` or `Installing...`
  final String status;

  /// The value of the progress, from 0.0 to 1.0.
  ///
  /// Setting this to null indicates a indeterminate progress bar.
  double? value;

  /// Overrides the default reading as a percent with a different text.
  ///
  /// Useful for indicating discrete progress, like `3/10` instead of `30%`.
  String? label;
}
