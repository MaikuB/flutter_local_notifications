import "package:xml/xml.dart";

import "notification_part.dart";

/// A group of notification content that must be displayed as a whole.
///
/// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-group
class WindowsGroup {
  /// Makes a group of multiple columns.
  const WindowsGroup(this.columns);

  /// The different columns being grouped together.
  final List<WindowsColumn> columns;

  /// Serializes this group to XML.
  void toXml(XmlBuilder builder) => builder.element(
    "group",
    nest: () {
      for (final column in columns) {
        builder.element(
          "subgroup",
          attributes: <String, String>{"hint-weight": "1"},
          nest: () {
            for (final part in column.parts) {
              part.toXml(builder);
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
