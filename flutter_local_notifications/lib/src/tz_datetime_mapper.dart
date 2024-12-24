import 'package:timezone/timezone.dart';

import '../flutter_local_notifications.dart';

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
      'scheduledDateTimeISO8601': toIso8601String(),
    };
  }

  AndroidDateTime toAndroid() {
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

    return AndroidDateTime(
      scheduledDateTime: iso8601DateComponent,
      scheduledDateTimeIso8601: toIso8601String(),
      timezoneName: location.name,
    );
  }
}

extension DateTimeComponentsUtils on DateTimeComponents {
  AndroidDateTimeComponents toAndroid() => switch (this) {
    DateTimeComponents.dateAndTime => AndroidDateTimeComponents.dateAndTime,
    DateTimeComponents.dayOfMonthAndTime => AndroidDateTimeComponents.dayOfMonthAndTime,
    DateTimeComponents.dayOfWeekAndTime => AndroidDateTimeComponents.dayOfWeekAndTime,
    DateTimeComponents.time => AndroidDateTimeComponents.time,
  };
}

extension RepeatIntervalUtils on RepeatInterval {
  AndroidRepeatInterval toAndroid() => switch (this) {
    RepeatInterval.daily => AndroidRepeatInterval.daily,
    RepeatInterval.everyMinute => AndroidRepeatInterval.everyMinute,
    RepeatInterval.hourly => AndroidRepeatInterval.hourly,
    RepeatInterval.weekly => AndroidRepeatInterval.weekly,
  };
}
