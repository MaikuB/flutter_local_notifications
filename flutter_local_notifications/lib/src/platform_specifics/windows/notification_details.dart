/// Contains notification details specific to Windows
class WindowsNotificationDetails {
  /// Constructs an instance of [WindowsNotificationDetails].
  const WindowsNotificationDetails({this.rawXml});

  /// Pass raw XML text to windows api. It will override title and body options.
  /// Reference: https://docs.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/adaptive-interactive-toasts?tabs=xml
  final String? rawXml;
}
