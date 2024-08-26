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
}
