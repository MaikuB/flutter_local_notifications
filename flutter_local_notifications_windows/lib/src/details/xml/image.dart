import 'package:xml/xml.dart';

import '../notification_parts.dart';

/// Converts a [WindowsImage] to XML
extension ImageToXml on WindowsImage {
  /// Serializes this image to Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-image
  void buildXml(XmlBuilder builder) {
    if (!file.isAbsolute) {
      throw ArgumentError.value(
        file.path,
        'WindowsImage.file',
        'File path must be absolute',
      );
    }
    builder.element(
      'image',
      attributes: <String, String>{
        'src': Uri.file(file.absolute.path, windows: true).toFilePath(),
        'alt': altText,
        'addImageQuery': addQueryParams.toString(),
        if (placement != null) 'placement': placement!.name,
        if (crop != null) 'hint-crop': crop!.name,
      },
    );
  }
}
