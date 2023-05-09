/// The Linux implementation of `flutter_local_notifications`.
library flutter_local_notifications_linux;

// flutter_local_notifications_linux depends on posix
// which uses FFI internally; export a stub for platforms that don't
// support FFI (e.g., web) to avoid having transitive dependencies
// break web compilation.
export 'src/flutter_local_notifications_stub.dart'
    if (dart.library.ffi) 'src/flutter_local_notifications.dart';
export 'src/model/capabilities.dart';
export 'src/model/enums.dart';
export 'src/model/icon.dart';
export 'src/model/initialization_settings.dart';
export 'src/model/location.dart';
export 'src/model/notification_details.dart';
export 'src/model/sound.dart';
export 'src/model/timeout.dart';
