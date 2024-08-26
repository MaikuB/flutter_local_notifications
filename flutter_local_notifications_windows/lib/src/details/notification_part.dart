/// A text or image element in a Windows notification.
///
/// Note: This should not be used for anything else as notification
/// groups can only contain text and images.
// This class needs to be abstract so [WindowsNotificationText] and
// [WindowsImage] can extend it. Specifically, this class is a marker
// type for classes that are valid as part of a [WindowsColumn].
// ignore: one_member_abstracts
abstract class WindowsNotificationPart {
  /// A const constructor.
  const WindowsNotificationPart();
}
