import 'package:xml/xml.dart';

import '../notification_progress.dart';

/// Converts a [WindowsProgressBar] to XML
extension ProgressBarToXml on WindowsProgressBar {
  /// Serializes this progress bar to Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-progress
  void buildXml(XmlBuilder builder) => builder.element(
        'progress',
        attributes: <String, String>{
          'status': status,
          'value': '{$id-progressValue}',
          if (title != null) 'title': title!,
          if (label != null) 'valueStringOverride': '{$id-progressString}',
        },
      );

  /// The data bindings for this progress bar.
  ///
  /// To support dynamic updates, [buildXml] will inject placeholder strings
  /// called data bindings instead of actual values. This can then be updated
  /// dynamically later by calling
  /// [FlutterLocalNotificationsWindows.updateProgressBar].
  Map<String, String> get data => <String, String>{
        '$id-progressValue': value?.toString() ?? 'indeterminate',
        if (label != null) '$id-progressString': label!,
      };
}
