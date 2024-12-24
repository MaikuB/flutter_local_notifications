@ConfigurePigeon(PigeonOptions(
  dartPackageName: 'flutter_local_notifications',
  dartOut: 'lib/src/android_messages.g.dart',
  dartOptions: DartOptions(),
  javaOptions: JavaOptions(),
  javaOut: 'android/src/main/java/com/dexterous/flutterlocalnotifications/Messages.java',
))
library;

import 'package:pigeon/pigeon.dart';

class MyMessage {
  const MyMessage({
    required this.name,
    required this.repeats,
  });

  final String name;
  final bool repeats;
}

@HostApi()
abstract class MyApi {
  void show(MyMessage message);
  void cancelAll();
}
