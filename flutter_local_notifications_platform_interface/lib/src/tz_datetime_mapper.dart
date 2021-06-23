import 'package:timezone/timezone.dart';

// ignore_for_file: public_member_api_docs
extension TZDateTimeMapper on TZDateTime {
  Map<String, Object> toMap() {
    String twoDigits(int n) {
      if (n >= 10) {
        return '$n';
      }
      return '0$n';
    }

    final String offsetMinutesComponent =
        twoDigits(timeZoneOffset.inMinutes.remainder(60));
    final int offsetHoursComponent =
        (timeZoneOffset.inMicroseconds ~/ Duration.microsecondsPerHour).abs();
    final String iso8601OffsetComponent =
        '${timeZoneOffset.isNegative ? '-' : '+'}${twoDigits(offsetHoursComponent)}$offsetMinutesComponent'; // ignore: lines_longer_than_80_chars
    final String iso8601DateComponent = toIso8601String()
        .split('.')[0]
        .replaceAll(iso8601OffsetComponent, '')
        .replaceAll('Z', '');

    return <String, Object>{
      'timeZoneName': location.name,
      'scheduledDateTime': iso8601DateComponent,
    };
  }
}
