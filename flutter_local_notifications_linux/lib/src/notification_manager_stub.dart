import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

import '../flutter_local_notifications_linux.dart';

/// Stub implementation of Linux notification manager and client.
class LinuxNotificationManager {
  /// Constructs an instance of of [LinuxNotificationManager]
  LinuxNotificationManager();

  /// Constructs an instance of of [LinuxNotificationManager]
  /// with the given class dependencies.
  @visibleForTesting
  LinuxNotificationManager.private();

  /// Initializes the manager.
  /// Call this method on application before using the manager further.
  Future<bool> initialize(
    LinuxInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    throw UnimplementedError();
  }

  /// Show notification
  Future<void> show(
    int id,
    String? title,
    String? body, {
    LinuxNotificationDetails? details,
    String? payload,
  }) async {}

  /// Cancel notification with the given [id].
  Future<void> cancel(int id) async {
    throw UnimplementedError();
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    throw UnimplementedError();
  }

  /// Returns the system notification server capabilities.
  Future<LinuxServerCapabilities> getCapabilities() async {
    throw UnimplementedError();
  }

  /// Returns a [Map] with the specified notification id as the key
  /// and the id, assigned by the system, as the value.
  Future<Map<int, int>> getSystemIdMap() async {
    throw UnimplementedError();
  }
}
