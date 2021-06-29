import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Provides Linux platform-specific info
// ignore: one_member_abstracts
abstract class LinuxPlatformInfo {
  /// Returns all platform-specific info
  Future<LinuxPlatformInfoData> getAll();
}

/// Real implementation of [LinuxPlatformInfo]
class LinuxPlatformInfoImpl implements LinuxPlatformInfo {
  @override
  Future<LinuxPlatformInfoData> getAll() async {
    try {
      final String exePath =
          await File('/proc/self/exe').resolveSymbolicLinks();
      final String appPath = path.dirname(exePath);
      final String assetPath = path.join(appPath, 'data', 'flutter_assets');
      final String versionPath = path.join(assetPath, 'version.json');
      final Map<String, dynamic> json = jsonDecode(
        await File(versionPath).readAsString(),
      );

      return LinuxPlatformInfoData(
        appName: json['app_name'] ?? '',
        assetsPath: assetPath,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return LinuxPlatformInfoData();
    }
  }
}

/// Represents Linux platform-specific info
class LinuxPlatformInfoData {
  /// Constructs an instance of [LinuxPlatformInfoData].
  LinuxPlatformInfoData({
    this.appName,
    this.assetsPath,
  });

  /// Application name
  final String? appName;

  /// Path to the Flutter Assets directory
  final String? assetsPath;
}
