import 'package:intl/intl.dart';

/// Localized number formatting for counts and quantities.
///
/// Dart's string interpolation always writes Latin digits, while [DateFormat]
/// and [NumberFormat] write Arabic-Indic ones under an `ar` locale. Without
/// this the same screen shows "20" beside "٢ نوفمبر", so every count that is
/// rendered next to a date or a price goes through here.
///
/// Identifiers are deliberately excluded: an order is `#31` in both languages,
/// because it is a label rather than a quantity.
abstract final class NumberFormatter {
  static String count(int value, String locale) =>
      NumberFormat.decimalPattern(locale).format(value);

  static String percent(double fraction, String locale) =>
      NumberFormat.percentPattern(locale).format(fraction);
}
