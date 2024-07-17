import "package:xml/xml.dart";

/// A text or image element in a Windows notification.
///
/// Note: This should not be used for anything else as notification
/// groups can only contain text and images.
abstract class WindowsNotificationPart {
  /// A const constructor.
  const WindowsNotificationPart();

  /// Serializes this part to XML, according to the Windows API.
  void toXml(XmlBuilder builder);
}
