import 'dart:async';

import 'package:dbus/dbus.dart';

/// Mockable [DBusRemoteObject] wrapper
class DBusWrapper {
  late final DBusRemoteObject _object;
  late final String _destination;

  /// Build an instance of [DBusRemoteObject]
  void build({
    required String destination,
    required String path,
  }) {
    _destination = destination;
    _object = DBusRemoteObject(
      DBusClient.session(),
      name: destination,
      path: DBusObjectPath(path),
    );
  }

  /// Invokes a method on this [DBusRemoteObject].
  /// Throws [DBusMethodResponseException] if the remote side returns an error.
  ///
  /// If [replySignature] is provided this causes this method to throw a
  /// [DBusReplySignatureException] if the result is successful but the returned
  /// values do not match the provided signature.
  Future<DBusMethodSuccessResponse> callMethod(
    String? interface,
    String name,
    Iterable<DBusValue> values, {
    DBusSignature? replySignature,
    bool noReplyExpected = false,
    bool noAutoStart = false,
    bool allowInteractiveAuthorization = false,
  }) =>
      _object.callMethod(
        interface,
        name,
        values,
        replySignature: replySignature,
        noReplyExpected: noReplyExpected,
        noAutoStart: noAutoStart,
        allowInteractiveAuthorization: allowInteractiveAuthorization,
      );

  /// Creates a stream of signal with the given [name].
  DBusRemoteObjectSignalStream subscribeSignal(String name) =>
      DBusRemoteObjectSignalStream(
          object: _object, interface: _destination, name: name);
}
