import 'package:xml/xml.dart';

import '../notification_header.dart';

/// Converts a [WindowsHeader] to XML
extension HeaderToXml on WindowsHeader {
  /// Serializes this header to XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-header
  void buildXml(XmlBuilder builder) => builder.element(
        'header',
        attributes: <String, String>{
          'id': id,
          'title': title,
          'arguments': arguments,
          if (activation != null) 'activationType': activation!.name,
        },
      );
}
