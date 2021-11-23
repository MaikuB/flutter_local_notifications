import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

class FakeStreamSubscription<T> extends Fake implements StreamSubscription<T> {}
