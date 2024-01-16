/// Data class that represent current state of notification options.
///
/// Used for Darwin systems, like iOS and macOS.
class NotificationsEnabledOptions {
  /// Constructs an instance of [NotificationsEnabledOptions]
  const NotificationsEnabledOptions({
    required this.isEnabled,
    required this.isSoundEnabled,
    required this.isAlertEnabled,
    required this.isBadgeEnabled,
    required this.isProvisionalEnabled,
    required this.isCriticalEnabled,
  });

  /// Whenever notifications are enabled.
  ///
  /// Can be either [isEnabled] or [isProvisionalEnabled].
  final bool isEnabled;

  /// Whenever sound notifications are enabled.
  final bool isSoundEnabled;

  /// Whenever alert notifications are enabled.
  final bool isAlertEnabled;

  /// Whenever badge notifications are enabled.
  final bool isBadgeEnabled;

  /// Whenever provisional notifications are enabled.
  ///
  /// Can be either [isEnabled] or [isProvisionalEnabled].
  final bool isProvisionalEnabled;

  /// Whenever critical notifications are enabled.
  final bool isCriticalEnabled;
}
