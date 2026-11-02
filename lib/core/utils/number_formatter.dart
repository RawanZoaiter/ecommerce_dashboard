import 'package:intl/intl.dart';

/// Localized number formatting for counts, quantities and shares.
///
/// Using this instead of string interpolation gives grouping separators and
/// the locale's own percent sign, so 1234 reads as `1,234` rather than running
/// together in a dense table.
///
/// It does not change the digit system: Dart's `intl` renders `ar` numbers
/// with Latin digits while `ar` dates come out in Arabic-Indic ones, so the
/// Arabic UI mixes the two. Prices are Latin as well, since
/// [NumberFormat.currency] behaves the same way. Settling on one system is a
/// product decision, noted in the README rather than forced here.
///
/// Identifiers are deliberately excluded: an order is `#31` in both languages,
/// because it is a label rather than a quantity, and grouping separators would
/// turn order 1234 into `#1,234`.
abstract final class NumberFormatter {
  static String count(int value, String locale) =>
      NumberFormat.decimalPattern(locale).format(value);

  static String percent(double fraction, String locale) =>
      NumberFormat.percentPattern(locale).format(fraction);
}
