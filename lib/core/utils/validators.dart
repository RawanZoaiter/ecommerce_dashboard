import '../../l10n/generated/app_localizations.dart';

/// Client-side copies of the server's validation rules.
///
/// These exist to give instant feedback, not to be trusted: the server
/// validates again and its 422 response is what actually decides. Each rule
/// mirrors the exact limits written in the guide, so the two agree.
abstract final class Validators {
  static final _emailPattern = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  /// §5.10: digits only, at most two decimals, greater than zero.
  static final _pricePattern = RegExp(r'^\d+(\.\d{1,2})?$');

  static String? email(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.loginErrorEmailRequired;
    if (!_emailPattern.hasMatch(text)) return l10n.loginErrorEmailInvalid;
    return null;
  }

  /// §5.2: at least 8 characters.
  static String? password(String? value, AppLocalizations l10n) {
    final text = value ?? '';
    if (text.isEmpty) return l10n.loginErrorPasswordRequired;
    if (text.length < 8) return l10n.loginErrorPasswordTooShort;
    return null;
  }

  static String? productName(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.productFormErrorName;
    if (text.length > 255) return l10n.productFormErrorNameTooLong;
    return null;
  }

  static String? productDescription(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.productFormErrorDescription;
    if (text.length > 5000) return l10n.productFormErrorDescriptionTooLong;
    return null;
  }

  static String? price(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.productFormErrorPrice;
    if (!_pricePattern.hasMatch(text)) return l10n.productFormErrorPriceFormat;
    if (double.parse(text) <= 0) return l10n.productFormErrorPriceZero;
    return null;
  }
}
