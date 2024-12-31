import 'package:xml/xml.dart';
import '../notification_action.dart';

/// Converts a [WindowsAction] to XML
extension ActionToXml on WindowsAction {
  /// Serializes this notification action as Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-action#syntax
  void buildXml(XmlBuilder builder) {
    builder.element(
      'action',
      attributes: <String, String>{
        'content': content,
        'arguments': arguments,
        'activationType': activationType.name,
        'afterActivationBehavior': activationBehavior.name,
        if (placement != null) 'placement': placement!.name,
        if (imageUri != null) 'imageUri': imageUri!.toString(),
        if (inputId != null) 'hint-inputId': inputId!,
        if (buttonStyle != null) 'hint-buttonStyle': buttonStyle!.name,
        if (tooltip != null) 'hint-toolTip': tooltip!,
      },
    );
  }
}
