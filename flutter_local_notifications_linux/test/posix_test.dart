import 'dart:io';

import 'package:flutter_local_notifications_linux/src/posix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('POSIX |', () {
    late Posix posix;

    setUpAll(() {
      posix = Posix();
    });

    test('getpid', () {
      expect(posix.getpid(), equals(pid));
    });
  });
}
