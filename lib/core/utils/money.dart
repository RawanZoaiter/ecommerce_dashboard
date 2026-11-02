import 'package:intl/intl.dart';

/// An exact money amount, held as whole minor units (piastres/cents).
///
/// The API sends prices as strings with two decimals and the guide says not to
/// do floating-point arithmetic on them (§5.8). `double` cannot represent
/// 899.50 exactly, so summing order lines in `double` drifts by fractions of a
/// unit and the dashboard total stops matching the server's. Keeping an [int]
/// of minor units makes every sum here exact.
class Money implements Comparable<Money> {
  const Money.fromMinorUnits(this.minorUnits);

  /// Parses the API's decimal string, e.g. `"899.50"`.
  ///
  /// Returns [Money.zero] for anything unparseable rather than throwing: a
  /// malformed price should leave a row showing 0.00, not break the table.
  factory Money.parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return Money.zero;

    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(trimmed);
    if (match == null) return Money.zero;

    final whole = int.parse(match.group(1)!);
    final fraction = match.group(2) ?? '';
    final minor = switch (fraction.length) {
      0 => 0,
      1 => int.parse(fraction) * 10,
      _ => int.parse(fraction),
    };
    return Money.fromMinorUnits(whole * 100 + minor);
  }

  static const Money zero = Money.fromMinorUnits(0);

  final int minorUnits;

  Money operator +(Money other) =>
      Money.fromMinorUnits(minorUnits + other.minorUnits);

  Money operator -(Money other) =>
      Money.fromMinorUnits(minorUnits - other.minorUnits);

  /// Unit price times an integer quantity — still exact.
  Money times(int quantity) => Money.fromMinorUnits(minorUnits * quantity);

  static Money sum(Iterable<Money> amounts) =>
      amounts.fold(Money.zero, (total, amount) => total + amount);

  /// The exact string the API expects back, e.g. `"899.50"`.
  String get apiValue {
    final major = minorUnits ~/ 100;
    final minor = (minorUnits % 100).abs().toString().padLeft(2, '0');
    return '$major.$minor';
  }

  /// Localized for display, e.g. `$899.50` or `٨٩٩٫٥٠ $`.
  String format({required String locale, String symbol = r'$'}) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    ).format(minorUnits / 100);
  }

  /// Short form for dense cards, e.g. `$12.4K`.
  String formatCompact({required String locale, String symbol = r'$'}) {
    final value = minorUnits / 100;
    if (value < 1000) return format(locale: locale, symbol: symbol);
    return symbol +
        NumberFormat.compactCurrency(
          locale: locale,
          symbol: '',
        ).format(value).trim();
  }

  @override
  int compareTo(Money other) => minorUnits.compareTo(other.minorUnits);

  @override
  bool operator ==(Object other) =>
      other is Money && other.minorUnits == minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;

  @override
  String toString() => 'Money($apiValue)';
}
