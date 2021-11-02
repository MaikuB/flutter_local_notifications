import 'package:dbus/dbus.dart';
import 'package:flutter_local_notifications_linux/src/dbus_wrapper.dart';
import 'package:mocktail/mocktail.dart';

class MockDBusWrapper extends Mock implements DBusWrapper {}

class MockDBusRemoteObject extends Mock implements DBusRemoteObject {}

class MockDBusRemoteObjectSignalStream extends Mock
    implements DBusRemoteObjectSignalStream {}
