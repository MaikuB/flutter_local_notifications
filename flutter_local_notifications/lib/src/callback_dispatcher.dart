import 'package:flutter/widgets.dart';

void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  print('ok, dispatcher called!');
}
