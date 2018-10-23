part of flutter_local_notifications;

void _callbackDispatcher() {
  const MethodChannel _backgroundChannel =
      MethodChannel('dexterous.com/flutter/local_notifications_background');
  WidgetsFlutterBinding.ensureInitialized();

  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'onNotification') {
      final Function callback = PluginUtilities.getCallbackFromHandle(
          CallbackHandle.fromRawHandle(call.arguments['callbackDispatcher']));
      assert(callback != null);
      callback(call.arguments['id'], call.arguments['title'],
          call.arguments['body'], call.arguments['payload']);
    }
  });
  _backgroundChannel.invokeMethod('initializedHeadlessService');
}
