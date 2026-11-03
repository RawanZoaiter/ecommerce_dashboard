import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colors that Material's [ColorScheme] has no slot for: order-status accents,
/// table chrome and the chart ramp. Exposed as a [ThemeExtension] so widgets
/// read them through `Theme.of(context)` like any other themed value.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccessContainer,
    required this.successContainer,
    required this.warning,
    required this.onWarningContainer,
    required this.warningContainer,
    required this.danger,
    required this.onDangerContainer,
    required this.dangerContainer,
    required this.info,
    required this.onInfoContainer,
    required this.infoContainer,
    required this.statusPending,
    required this.statusConfirmed,
    required this.statusShipped,
    required this.statusDelivered,
    required this.statusCancelled,
    required this.border,
    required this.borderStrong,
    required this.surfaceSunken,
    required this.surfaceRaised,
    required this.chart,
  });

  final Color success;
  final Color onSuccessContainer;
  final Color successContainer;
  final Color warning;
  final Color onWarningContainer;
  final Color warningContainer;
  final Color danger;
  final Color onDangerContainer;
  final Color dangerContainer;
  final Color info;
  final Color onInfoContainer;
  final Color infoContainer;

  final Color statusPending;
  final Color statusConfirmed;
  final Color statusShipped;
  final Color statusDelivered;
  final Color statusCancelled;

  final Color border;
  final Color borderStrong;
  final Color surfaceSunken;
  final Color surfaceRaised;

  /// Ordered categorical ramp for charts; cycle it rather than inventing colors.
  final List<Color> chart;

  static const light = AppSemanticColors(
    success: AppColors.emerald600,
    successContainer: Color(0xFFD1FAE5),
    onSuccessContainer: Color(0xFF065F46),
    warning: AppColors.amber600,
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF92400E),
    danger: AppColors.rose600,
    dangerContainer: Color(0xFFFFE4E6),
    onDangerContainer: Color(0xFF9F1239),
    info: AppColors.sky600,
    infoContainer: Color(0xFFE0F2FE),
    onInfoContainer: Color(0xFF075985),
    statusPending: AppColors.amber500,
    statusConfirmed: AppColors.sky500,
    statusShipped: AppColors.violet500,
    statusDelivered: AppColors.emerald500,
    statusCancelled: AppColors.rose500,
    border: AppColors.slate200,
    borderStrong: AppColors.slate300,
    surfaceSunken: AppColors.slate50,
    surfaceRaised: Colors.white,
    chart: [
      AppColors.brand500,
      AppColors.emerald500,
      AppColors.amber500,
      AppColors.sky500,
      AppColors.violet500,
      AppColors.rose500,
    ],
  );

  static const dark = AppSemanticColors(
    success: Color(0xFF34D399),
    successContainer: Color(0xFF064E3B),
    onSuccessContainer: Color(0xFFA7F3D0),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF78350F),
    onWarningContainer: Color(0xFFFDE68A),
    danger: Color(0xFFFB7185),
    dangerContainer: Color(0xFF881337),
    onDangerContainer: Color(0xFFFECDD3),
    info: Color(0xFF38BDF8),
    infoContainer: Color(0xFF0C4A6E),
    onInfoContainer: Color(0xFFBAE6FD),
    statusPending: Color(0xFFFBBF24),
    statusConfirmed: Color(0xFF38BDF8),
    statusShipped: Color(0xFFA78BFA),
    statusDelivered: Color(0xFF34D399),
    statusCancelled: Color(0xFFFB7185),
    border: Color(0xFF1E293B),
    borderStrong: Color(0xFF334155),
    surfaceSunken: AppColors.slate950,
    surfaceRaised: Color(0xFF111B2E),
    chart: [
      AppColors.brand400,
      Color(0xFF34D399),
      Color(0xFFFBBF24),
      Color(0xFF38BDF8),
      Color(0xFFA78BFA),
      Color(0xFFFB7185),
    ],
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccessContainer,
    Color? successContainer,
    Color? warning,
    Color? onWarningContainer,
    Color? warningContainer,
    Color? danger,
    Color? onDangerContainer,
    Color? dangerContainer,
    Color? info,
    Color? onInfoContainer,
    Color? infoContainer,
    Color? statusPending,
    Color? statusConfirmed,
    Color? statusShipped,
    Color? statusDelivered,
    Color? statusCancelled,
    Color? border,
    Color? borderStrong,
    Color? surfaceSunken,
    Color? surfaceRaised,
    List<Color>? chart,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      info: info ?? this.info,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      statusPending: statusPending ?? this.statusPending,
      statusConfirmed: statusConfirmed ?? this.statusConfirmed,
      statusShipped: statusShipped ?? this.statusShipped,
      statusDelivered: statusDelivered ?? this.statusDelivered,
      statusCancelled: statusCancelled ?? this.statusCancelled,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      chart: chart ?? this.chart,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      success: mix(success, other.success),
      onSuccessContainer: mix(onSuccessContainer, other.onSuccessContainer),
      successContainer: mix(successContainer, other.successContainer),
      warning: mix(warning, other.warning),
      onWarningContainer: mix(onWarningContainer, other.onWarningContainer),
      warningContainer: mix(warningContainer, other.warningContainer),
      danger: mix(danger, other.danger),
      onDangerContainer: mix(onDangerContainer, other.onDangerContainer),
      dangerContainer: mix(dangerContainer, other.dangerContainer),
      info: mix(info, other.info),
      onInfoContainer: mix(onInfoContainer, other.onInfoContainer),
      infoContainer: mix(infoContainer, other.infoContainer),
      statusPending: mix(statusPending, other.statusPending),
      statusConfirmed: mix(statusConfirmed, other.statusConfirmed),
      statusShipped: mix(statusShipped, other.statusShipped),
      statusDelivered: mix(statusDelivered, other.statusDelivered),
      statusCancelled: mix(statusCancelled, other.statusCancelled),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      chart: [
        for (var i = 0; i < chart.length; i++)
          mix(chart[i], other.chart[i % other.chart.length]),
      ],
    );
  }
}
