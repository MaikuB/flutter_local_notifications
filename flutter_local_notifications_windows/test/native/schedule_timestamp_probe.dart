import 'dart:ffi';

import 'package:flutter_local_notifications_windows/src/ffi/bindings.dart';
import 'package:test/test.dart';
import 'package:ffi/ffi.dart';

void main() {
  test('schedule FFI preserves signed 64-bit Unix seconds', () {
    final DynamicLibrary fixture = DynamicLibrary.open(
      'flutter_local_notifications_timestamp_fixture.dll',
    );
    Pointer<T> lookup<T extends NativeType>(String name) {
      expect(
        T,
        NativeFunction<
          Bool Function(Pointer<NativePlugin>, Int, Pointer<Utf8>, Int64)
        >,
      );
      return fixture.lookup<T>(name);
    }

    final NotificationsPluginBindings bindings =
        NotificationsPluginBindings.fromLookup(lookup);
    final int Function() captured = fixture
        .lookupFunction<Int64 Function(), int Function()>('capturedTimestamp');
    for (final int seconds in <int>[
      -1,
      2114380800,
      2147483647,
      2147483648,
      2208988800,
      4102444800,
      7258118400,
    ]) {
      expect(
        bindings.scheduleNotification(nullptr, 1, nullptr, seconds),
        isTrue,
      );
      expect(captured(), seconds);
    }
  });
}
