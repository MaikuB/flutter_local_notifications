class NotificationsEnabledOptions {
  const NotificationsEnabledOptions({
    required this.isEnabled,
    required this.isSoundEnabled,
    required this.isAlertEnabled,
    required this.isBadgeEnabled,
    required this.isProvisionalEnabled,
    required this.isCriticalEnabled,
  });

  final bool isEnabled;
  final bool isSoundEnabled;
  final bool isAlertEnabled;
  final bool isBadgeEnabled;
  final bool isProvisionalEnabled;
  final bool isCriticalEnabled;
}
