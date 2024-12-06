import 'package:xml/xml.dart';

import '../notification_input.dart';

/// Converts a [WindowsTextInput] to XML
extension TextInputToXml on WindowsTextInput {
  /// Serializes this input to Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-input
  void buildXml(XmlBuilder builder) => builder.element(
        'input',
        attributes: <String, String>{
          'id': id,
          'type': type.name,
          if (title != null) 'title': title!,
          if (placeHolderContent != null)
            'placeHolderContent': placeHolderContent!,
        },
      );
}

/// Converts a [WindowsSelectionInput] to XML
extension SelectionInputToXml on WindowsSelectionInput {
  /// Serializes this input to Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-input
  void buildXml(XmlBuilder builder) => builder.element(
        'input',
        attributes: <String, String>{
          'id': id,
          'type': type.name,
          if (title != null) 'title': title!,
          if (defaultItem != null) 'defaultInput': defaultItem!,
        },
        nest: () {
          for (final WindowsSelection item in items) {
            item.buildXml(builder);
          }
        },
      );
}

/// Converts a [WindowsSelection] to XML
extension SelectionToXml on WindowsSelection {
  /// Serializes this selection to Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-selection
  void buildXml(XmlBuilder builder) => builder.element(
        'selection',
        attributes: <String, String>{
          'id': id,
          'content': content,
        },
      );
}
