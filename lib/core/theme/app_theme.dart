import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_semantic_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light({required bool arabic}) =>
      _build(Brightness.light, arabic: arabic);

  static ThemeData dark({required bool arabic}) =>
      _build(Brightness.dark, arabic: arabic);

  static ThemeData _build(Brightness brightness, {required bool arabic}) {
    final isDark = brightness == Brightness.dark;
    final semantic = isDark ? AppSemanticColors.dark : AppSemanticColors.light;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.brand400 : AppColors.brand600,
      onPrimary: isDark ? AppColors.slate950 : Colors.white,
      primaryContainer: isDark ? AppColors.brand900 : AppColors.brand50,
      onPrimaryContainer: isDark ? AppColors.brand100 : AppColors.brand800,
      secondary: isDark ? AppColors.slate400 : AppColors.slate600,
      onSecondary: isDark ? AppColors.slate950 : Colors.white,
      secondaryContainer: isDark ? AppColors.slate800 : AppColors.slate100,
      onSecondaryContainer: isDark ? AppColors.slate200 : AppColors.slate700,
      error: semantic.danger,
      onError: isDark ? AppColors.slate950 : Colors.white,
      errorContainer: semantic.dangerContainer,
      onErrorContainer: semantic.onDangerContainer,
      surface: semantic.surfaceRaised,
      onSurface: isDark ? AppColors.slate100 : AppColors.slate900,
      onSurfaceVariant: isDark ? AppColors.slate400 : AppColors.slate500,
      outline: semantic.borderStrong,
      outlineVariant: semantic.border,
      surfaceContainerLowest: semantic.surfaceSunken,
      surfaceContainerLow: isDark ? const Color(0xFF0B1424) : AppColors.slate50,
      surfaceContainer: isDark ? const Color(0xFF111B2E) : Colors.white,
      surfaceContainerHigh: isDark
          ? const Color(0xFF16213A)
          : AppColors.slate50,
      surfaceContainerHighest: isDark
          ? const Color(0xFF1B2846)
          : AppColors.slate100,
      inverseSurface: isDark ? AppColors.slate100 : AppColors.slate900,
      onInverseSurface: isDark ? AppColors.slate900 : AppColors.slate50,
    );

    final textTheme = AppTypography.textTheme(
      arabic: arabic,
      onSurface: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: semantic.surfaceSunken,
      textTheme: textTheme,
      fontFamily: arabic ? AppTypography.arabicFont : AppTypography.latinFont,
      extensions: [semantic],
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: semantic.border),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: semantic.border,
        thickness: 1,
        space: 1,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: textTheme.labelLarge,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: semantic.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerLow : Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        enabledBorder: _border(semantic.border),
        border: _border(semantic.border),
        focusedBorder: _border(scheme.primary, width: 1.6),
        errorBorder: _border(scheme.error),
        focusedErrorBorder: _border(scheme.error, width: 1.6),
        disabledBorder: _border(semantic.border),
      ),

      chipTheme: ChipThemeData(
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: semantic.border),
        ),
        textStyle: textTheme.bodyMedium,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: semantic.border,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          scheme.onSurfaceVariant.withValues(alpha: 0.35),
        ),
        radius: const Radius.circular(AppRadius.pill),
        thickness: const WidgetStatePropertyAll(8),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
