import 'package:xml/xml.dart';

import '../notification_parts.dart';
import '../notification_row.dart';

import 'image.dart';
import 'text.dart';

/// Converts a [WindowsRow] to XML
extension RowToXml on WindowsRow {
  /// Serializes this group to XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-group
  void buildXml(XmlBuilder builder) => builder.element(
        'group',
        nest: () {
          for (final WindowsColumn column in columns) {
            builder.element(
              'subgroup',
              attributes: <String, String>{'hint-weight': '1'},
              nest: () {
                for (final WindowsNotificationPart part in column.parts) {
                  switch (part) {
                    case WindowsImage():
                      part.buildXml(builder);
                    case WindowsNotificationText():
                      part.buildXml(builder);
                  }
                }
              },
            );
          }
        },
      );
}
