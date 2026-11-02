import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

enum BannerTone { info, warning, danger }

/// An inline notice: the sample-data badge, or a warning that a backing
/// service is down.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.message,
    this.title,
    this.tone = BannerTone.info,
    this.icon,
    this.action,
    super.key,
  });

  final String message;
  final String? title;
  final BannerTone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;

    final (background, foreground, accent, fallbackIcon) = switch (tone) {
      BannerTone.info => (
        semantic.infoContainer,
        semantic.onInfoContainer,
        semantic.info,
        Icons.info_outline,
      ),
      BannerTone.warning => (
        semantic.warningContainer,
        semantic.onWarningContainer,
        semantic.warning,
        Icons.warning_amber_rounded,
      ),
      BannerTone.danger => (
        semantic.dangerContainer,
        semantic.onDangerContainer,
        semantic.danger,
        Icons.error_outline,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? fallbackIcon, size: 20, color: accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: context.text.titleSmall?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Text(
                  message,
                  style: context.text.bodySmall?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}
