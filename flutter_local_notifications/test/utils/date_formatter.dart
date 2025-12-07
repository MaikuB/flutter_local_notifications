import 'package:timezone/timezone.dart' as tz;

String convertDateToISO8601String(tz.TZDateTime dateTime) {
  String twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  String fourDigits(int n) {
    final int absN = n.abs();
    final String sign = n < 0 ? '-' : '';
    if (absN >= 1000) {
      return '$n';
    }
    if (absN >= 100) {
      return '${sign}0$absN';
    }
    if (absN >= 10) {
      return '${sign}00$absN';
    }
    return '${sign}000$absN';
  }

  return '${fourDigits(dateTime.year)}-${twoDigits(dateTime.month)}-${twoDigits(dateTime.day)}T${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}:${twoDigits(dateTime.second)}'; // ignore: lines_longer_than_80_chars
}
