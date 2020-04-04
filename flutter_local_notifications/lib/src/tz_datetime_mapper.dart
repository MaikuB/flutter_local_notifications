import 'package:timezone/timezone.dart';

extension TZDateTimeMapper on TZDateTime {
  Map<String, Object> toMap() {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    final String offsetMinutesComponent =
        twoDigits(this.timeZoneOffset.inMinutes.remainder(60));
    final int offsetHoursComponent =
        (this.timeZoneOffset.inMicroseconds ~/ Duration.microsecondsPerHour)
            .abs();
    final iso8601OffsetComponent =
        '${this.timeZoneOffset.isNegative ? '-' : '+'}${twoDigits(offsetHoursComponent)}$offsetMinutesComponent';
    final String iso8601DateComponent = this
        .toIso8601String()
        .split('.')[0]
        .replaceAll(iso8601OffsetComponent, '')
        .replaceAll('Z', '');

    return <String, Object>{
      'timezoneName': this.location.name,
      'scheduledDateTime': iso8601DateComponent,
    };
  }
}
