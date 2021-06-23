import 'types.dart';

// ignore_for_file: public_member_api_docs
extension TimeMapper on Time {
  Map<String, int> toMap() => <String, int>{
        'hour': hour,
        'minute': minute,
        'second': second,
      };
}
