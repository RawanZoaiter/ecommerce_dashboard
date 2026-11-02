import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';

/// Shorthands for the four things nearly every widget reads from context.
extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>()!;

  String get localeName => Localizations.localeOf(this).toLanguageTag();
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Phone and small-tablet width: the side navigation becomes a drawer.
  bool get isCompact => screenWidth < AppBreakpoints.compact;

  /// Laptop width: the rail stays, but labels are hidden to save room.
  bool get isMedium =>
      screenWidth >= AppBreakpoints.compact &&
      screenWidth < AppBreakpoints.medium;

  bool get isExpanded => screenWidth >= AppBreakpoints.medium;

  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
