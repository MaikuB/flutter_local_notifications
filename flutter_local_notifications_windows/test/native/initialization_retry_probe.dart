// Manual probe, not run by `flutter test` (not a *_test.dart file). Build
// query_latency_stub.cpp as flutter_local_notifications_windows.dll first.
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_local_notifications_windows/src/ffi/bindings.dart'
    as native;

import 'package:flutter_local_notifications_windows/flutter_local_notifications_windows.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

void main() {
  setUpAll(initializeTimeZones);
  const WindowsInitializationSettings retrySettings =
      WindowsInitializationSettings(
        appName: 'initialization-probe',
        appUserModelId: 'com.test.retry',
        guid: 'a8c22b55-049e-422f-b30f-863694de08c8',
      );
  final DynamicLibrary fixture = DynamicLibrary.open(
    'flutter_local_notifications_windows.dll',
  );
  final void Function(int) setInitFailures = fixture
      .lookupFunction<Void Function(Int), void Function(int)>(
        'setInitFailures',
      );
  final int Function() createCount = fixture
      .lookupFunction<Int Function(), int Function()>('stubCreateCount');
  final int Function() destroyCount = fixture
      .lookupFunction<Int Function(), int Function()>('stubDestroyCount');
  final int Function() initCount = fixture
      .lookupFunction<Int Function(), int Function()>('stubInitCount');
  final int Function() scheduledTime = fixture
      .lookupFunction<Int64 Function(), int Function()>('stubScheduledTime');
  final int Function() callbackAddress = fixture
      .lookupFunction<UintPtr Function(), int Function()>(
        'stubCallbackAddress',
      );
  setUp(() => setInitFailures(0));

  Future<void> disposePlugin(FlutterLocalNotificationsWindows plugin) async {
    plugin.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 850));
  }

  test('the generated schedule binding requests a 64-bit timestamp', () {
    Pointer<T> lookup<T extends NativeType>(String name) {
      expect(
        T,
        NativeFunction<
          Bool Function(Pointer<native.NativePlugin>, Int, Pointer<Utf8>, Int64)
        >,
      );
      return fixture.lookup<T>(name);
    }

    final native.NotificationsPluginBindings bindings =
        native.NotificationsPluginBindings.fromLookup(lookup);
    expect(
      bindings.scheduleNotification(nullptr, 1, nullptr, 7258118400),
      isTrue,
    );
    expect(scheduledTime(), 7258118400);
  });

  test(
    'scheduled seconds cross the signed 32-bit boundary unchanged',
    () async {
      final FlutterLocalNotificationsWindows plugin =
          FlutterLocalNotificationsWindows();
      addTearDown(() => disposePlugin(plugin));
      expect(await plugin.initialize(settings: retrySettings), isTrue);
      for (final TZDateTime date in <TZDateTime>[
        TZDateTime(UTC, 2037, 1, 1),
        TZDateTime.fromMillisecondsSinceEpoch(UTC, 2147483647000),
        TZDateTime.fromMillisecondsSinceEpoch(UTC, 2147483648000),
        TZDateTime(UTC, 2040, 1, 1),
        TZDateTime(UTC, 2100, 1, 1),
        TZDateTime(UTC, 2200, 1, 1),
      ]) {
        final int expected = date.millisecondsSinceEpoch ~/ 1000;
        await plugin.zonedSchedule(id: 1, scheduledDate: date, title: 'future');
        expect(scheduledTime(), expected, reason: '$date normal schedule');
        await plugin.zonedScheduleRawXml(
          id: 1,
          xml: '<toast/>',
          scheduledDate: date,
        );
        expect(scheduledTime(), expected, reason: '$date raw XML schedule');
      }
    },
  );

  test('a failed registration can retry on one native plugin', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    addTearDown(() => disposePlugin(plugin));
    final int created = createCount();
    final int destroyed = destroyCount();
    final int initialized = initCount();
    setInitFailures(1);
    expect(await plugin.initialize(settings: retrySettings), isFalse);
    final int firstCallback = callbackAddress();
    await expectLater(plugin.pendingNotificationRequests(), throwsStateError);
    final Future<bool> first = plugin.initialize(settings: retrySettings);
    final Future<bool> shared = plugin.initialize(settings: retrySettings);
    expect(await Future.wait(<Future<bool>>[first, shared]), <bool>[
      true,
      true,
    ]);
    expect(createCount(), created + 1);
    expect(initCount(), initialized + 2);
    expect(destroyCount(), destroyed);
    expect(callbackAddress(), firstCallback);
  });

  test('repeated failed registrations remain explicitly disposable', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    addTearDown(() => disposePlugin(plugin));
    final int created = createCount();
    final int destroyed = destroyCount();
    setInitFailures(2);
    expect(await plugin.initialize(settings: retrySettings), isFalse);
    expect(await plugin.initialize(settings: retrySettings), isFalse);
    expect(createCount(), created + 1);
    expect(destroyCount(), destroyed);
    await disposePlugin(plugin);
    expect(destroyCount(), destroyed + 1);
    expect(plugin.initialize(settings: retrySettings), throwsStateError);
    plugin.dispose();
  });

  test('dispose during failed initialization releases one plugin', () async {
    final FlutterLocalNotificationsWindows plugin =
        FlutterLocalNotificationsWindows();
    final int destroyed = destroyCount();
    setInitFailures(1);
    final Future<bool> initializing = plugin.initialize(
      settings: retrySettings,
    );
    plugin.dispose();
    expect(await initializing, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    expect(destroyCount(), destroyed + 1);
    expect(plugin.initialize(settings: retrySettings), throwsStateError);
    plugin.dispose();
  });
}
