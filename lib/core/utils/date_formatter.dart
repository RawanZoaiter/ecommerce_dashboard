import 'package:intl/intl.dart';

/// Formatting for the ISO 8601 timestamps the API returns (guide §8).
abstract final class DateFormatter {
  /// Parses an API timestamp into local time, or null when it is malformed.
  static DateTime? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  /// `31 Oct 2026`
  static String date(DateTime value, String locale) =>
      DateFormat.yMMMd(locale).format(value);

  /// `31 Oct 2026, 8:40 PM`
  static String dateTime(DateTime value, String locale) =>
      '${DateFormat.yMMMd(locale).format(value)}, '
      '${DateFormat.jm(locale).format(value)}';

  /// `8:40 PM`
  static String time(DateTime value, String locale) =>
      DateFormat.jm(locale).format(value);

  /// `Mon`, for the weekly revenue chart axis.
  static String weekdayShort(DateTime value, String locale) =>
      DateFormat.E(locale).format(value);
}
