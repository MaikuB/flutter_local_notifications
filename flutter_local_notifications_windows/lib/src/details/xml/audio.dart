import 'package:xml/xml.dart';
import '../notification_audio.dart';

/// Converts a [WindowsNotificationAudio] to XML
extension AudioToXml on WindowsNotificationAudio {
  /// Serializes this audio to Windows-compatible XML.
  ///
  /// See: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-audio
  void buildXml(XmlBuilder builder) => builder.element(
        'audio',
        attributes: <String, String>{
          'src': source,
          'silent': isSilent.toString(),
          'loop': shouldLoop.toString(),
        },
      );
}
