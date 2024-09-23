import 'package:xml/xml.dart';

import '../notification_parts.dart';

/// Converts a [WindowsNotificationText] to XML
extension TextToXml on WindowsNotificationText {
  /// Serializes this text to Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-text
  void buildXml(XmlBuilder builder) => builder.element(
        'text',
        attributes: <String, String>{
          if (languageCode != null) 'lang': languageCode!,
          if (placement != null) 'placement': placement!.name,
          'hint-callScenarioCenterAlign': centerIfCall.toString(),
          'hint-align': 'center',
          if (isCaption) 'hint-style': 'captionsubtle',
        },
        nest: text,
      );
}
