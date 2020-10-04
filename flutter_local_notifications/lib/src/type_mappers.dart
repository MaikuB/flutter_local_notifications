import 'types.dart';

extension TimeMapper on Time {
  Map<String, int> toMap() => <String, int>{
        'hour': hour,
        'minute': minute,
        'second': second,
      };
}
