/// Decides how the application will open when the header is pressed.
enum WindowsHeaderActivation {
  /// Opens the app in the foreground.
  foreground,

  /// Opens any app using a custom protocol.
  protocol,
}

/// A header that groups multiple Windows notifications.
class WindowsHeader {
  /// Creates a Windows header.
  const WindowsHeader({
    required this.id,
    required this.title,
    required this.arguments,
    this.activation,
  });

  /// A unique ID for this header.
  final String id;

  /// The title of the header.
  final String title;

  /// An application-defined payload that will be passed back when pressed.
  final String arguments;

  /// Specifies how the application will open.
  final WindowsHeaderActivation? activation;
}
