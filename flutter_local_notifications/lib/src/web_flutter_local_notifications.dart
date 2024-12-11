export 'platform_specifics/web/details.dart';

export 'platform_specifics/web/stub.dart'
    if (dart.library.js_interop) 'platform_specifics/web/plugin.dart';
