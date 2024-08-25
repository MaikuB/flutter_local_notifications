import 'package:xml/xml.dart';

import 'notification_part.dart';

/// A group of notification content that must be displayed as a whole row.
///
/// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-group
class WindowsRow {
  /// Makes a group of multiple columns.
  const WindowsRow(this.columns);

  /// The different columns being grouped together.
  final List<WindowsColumn> columns;

  /// Serializes this group to XML.
  void buildXml(XmlBuilder builder) => builder.element(
    'group',
    nest: () {
      for (final WindowsColumn column in columns) {
        builder.element(
          'subgroup',
          attributes: <String, String>{'hint-weight': '1'},
          nest: () {
            for (final WindowsNotificationPart part in column.parts) {
              part.buildXml(builder);
            }
          },
        );
      }
    },
  );
}

/// A vertical column of text and images in a Windows notification.
class WindowsColumn {
  /// A const constructor.
  const WindowsColumn(this.parts);

  /// A list of text or images in this column.
  final List<WindowsNotificationPart> parts;
}
