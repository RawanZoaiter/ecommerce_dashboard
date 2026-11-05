import 'dart:ui';

import 'package:ecommerce_dashboard/core/utils/validators.dart';
import 'package:ecommerce_dashboard/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('email', () {
    test('accepts the addresses this project actually signs in with', () {
      // The dev admin account from the frontend guide. A rejection here is
      // what made the login screen refuse a correct address.
      expect(Validators.email('admin@example.com', l10n), isNull);
      expect(Validators.email('enass@example.com', l10n), isNull);
      expect(Validators.email('user.name+tag@sub.example.com', l10n), isNull);
      expect(Validators.email('a@b.co', l10n), isNull);
    });

    test('trims surrounding whitespace before judging', () {
      expect(Validators.email('  admin@example.com  ', l10n), isNull);
    });

    test('rejects what is not an address', () {
      expect(Validators.email('admin@', l10n), isNotNull);
      expect(Validators.email('admin@example', l10n), isNotNull);
      expect(Validators.email('no-at-sign', l10n), isNotNull);
      expect(Validators.email('', l10n), isNotNull);
      expect(Validators.email(null, l10n), isNotNull);
    });
  });

  group('password', () {
    test('accepts the dev admin password', () {
      expect(Validators.password('123456789', l10n), isNull);
    });

    test('rejects anything under the server minimum of 8', () {
      expect(Validators.password('1234567', l10n), isNotNull);
      expect(Validators.password('', l10n), isNotNull);
    });
  });

  group('price', () {
    test('accepts the decimal shapes the API documents', () {
      expect(Validators.price('899.50', l10n), isNull);
      expect(Validators.price('25', l10n), isNull);
      expect(Validators.price('0.5', l10n), isNull);
    });

    test('rejects letters, too many decimals and zero', () {
      expect(Validators.price('12.345', l10n), isNotNull);
      expect(Validators.price('abc', l10n), isNotNull);
      expect(Validators.price('0', l10n), isNotNull);
    });
  });
}
