import 'package:xml/xml.dart';

import '../../../flutter_local_notifications.dart';

/// A progress bar in a Windows notification.
///
/// To update the progress after the notification has been shown,
/// use [WindowsFlutterLocalNotificationsPlugin.updateProgress].
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

  /// Serializes this progress bar to XML.
  void toXml(XmlBuilder builder) => builder.element(
    'progress',
    attributes: <String, String>{
      'status': status,
      'value': '{$id-progressValue}',
      if (title != null) 'title': title!,
      if (label != null) 'valueStringOverride': '{$id-progressString}',
    }
  );

  /// The data bindings for this progress bar.
  ///
  /// To support dynamic updates, [toXml] will inject placeholder strings
  /// called data bindings instead of actual values. This represents the
  /// new data.
  Map<String, String> get data => <String, String>{
    '$id-progressValue': value?.toString() ?? 'indeterminate',
    if (label != null) '$id-progressString': label!
  };
}
