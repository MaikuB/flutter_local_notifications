import 'dart:io';

import 'package:flutter_local_notifications_linux/src/ffi/posix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('POSIX |', () {
    test('getpid', () {
       expect(getpid(), equals(pid));
    });
  });
}
