import 'package:ecommerce_dashboard/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('parses the API decimal string into exact minor units', () {
      expect(Money.parse('899.50').minorUnits, 89950);
      expect(Money.parse('25').minorUnits, 2500);
      expect(Money.parse('0.5').minorUnits, 50);
    });

    test('round-trips back to the API format', () {
      expect(Money.parse('899.50').apiValue, '899.50');
      expect(Money.parse('25').apiValue, '25.00');
    });

    test('falls back to zero instead of throwing on bad input', () {
      expect(Money.parse('abc'), Money.zero);
      expect(Money.parse(''), Money.zero);
      expect(Money.parse('12.345'), Money.zero);
    });

    test('sums order lines without floating point drift', () {
      // 0.10 + 0.20 is 0.30000000000000004 in double arithmetic, which is
      // exactly the error Money exists to avoid.
      final total = Money.sum([Money.parse('0.10'), Money.parse('0.20')]);
      expect(total.apiValue, '0.30');
    });

    test('multiplies a unit price by a quantity exactly', () {
      expect(Money.parse('899.50').times(3).apiValue, '2698.50');
    });
  });
}
