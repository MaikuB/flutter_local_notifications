import 'package:xml/xml.dart';
import '../notification_action.dart';

/// Converts a [WindowsAction] to XML
extension ActionToXml on WindowsAction {
  /// Serializes this notification action as Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-action#syntax
  void buildXml(XmlBuilder builder) {
    if (image != null && !image!.isAbsolute) {
      throw ArgumentError.value(
        image!.path,
        'WindowsImage.file',
        'File path must be absolute',
      );
    }
    builder.element(
      'action',
      attributes: <String, String>{
        'content': content,
        'arguments': arguments,
        'activationType': activationType.name,
        'afterActivationBehavior': activationBehavior.name,
        if (placement != null) 'placement': placement!.name,
        if (image != null)
          'imageUri':
              Uri.file(image!.absolute.path, windows: true).toFilePath(),
        if (inputId != null) 'hint-inputId': inputId!,
        if (buttonStyle != null) 'hint-buttonStyle': buttonStyle!.name,
        if (tooltip != null) 'hint-toolTip': tooltip!,
      },
    );
  }
}
