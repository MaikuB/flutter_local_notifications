import '../../flutter_local_notifications_windows.dart';

/// Helpful methods to support MSIX and package identity.
class MsixUtils {
  /// Returns whether the current app was installed with an MSIX installer.
  ///
  /// Using an MSIX grants your application [package identity](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/package-identity-overview),
  /// which allows it to use [certain APIs](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/modernize-packaged-apps).
  ///
  /// Specifically, using an MSIX installer allows your app to:
  /// - use [FlutterLocalNotificationsWindows.getActiveNotifications]
  /// - use [FlutterLocalNotificationsWindows.cancel]
  /// - use custom files for notification sounds
  /// - use network sources for notifications
  /// - use `ms-appx:///` URIs for resources
  ///
  /// These functions will simply do nothing or return empty data in apps
  /// without package identity. Additionally:
  /// - [WindowsImage.getAssetUri] will return a `file:///` or `ms-appx:///` URI,
  /// depending on whether the app is running in debug, release, or as an MSIX.
  /// - [WindowsNotificationAudio.asset] takes an audio file to use for apps
  /// with package identity, and a preset fallbacks for apps without.
  static bool hasPackageIdentity() => false; // platforms without FFI

  /// Gets an `ms-appx:///` URI from a [Flutter asset](https://docs.flutter.dev/ui/assets/assets-and-images).
  static Uri getAssetUri(String path) =>
      Uri.parse('ms-appx:///data/flutter_assets/$path');
}
