import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../../flutter_local_notifications_windows.dart';

// ignore: avoid_classes_with_only_static_members
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
  /// - [WindowsImage.assetUri] will return a `file:///` or `ms-appx:///` URI,
  /// depending on whether the app is running in debug, release, or as an MSIX.
  /// - [WindowsNotificationAudio.asset] takes an audio file to use for apps
  /// with package identity, and a preset fallbacks for apps without.
  static bool hasPackageIdentity() => using((Arena arena) {
        final bool? cached = _hasPackageIdentity;
        if (cached != null) {
          return cached;
        } else if (!Platform.isWindows) {
          return false;
        } else if (IsWindows8OrGreater() != 1) {
          return false;
        }
        final Pointer<Uint32> length = arena<Uint32>();
        final int error = GetCurrentPackageFullName(length, nullptr);
        final bool result = error != WIN32_ERROR.APPMODEL_ERROR_NO_PACKAGE;
        _hasPackageIdentity = result;
        return result;
      });

  static bool? _hasPackageIdentity;

  /// Gets an `ms-appx:///` URI from a [Flutter asset](https://docs.flutter.dev/ui/assets/assets-and-images).
  static Uri assetUri(String path) =>
      Uri.parse('ms-appx:///data/flutter_assets/$path');
}
