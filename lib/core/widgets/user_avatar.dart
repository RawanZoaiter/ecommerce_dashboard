import 'package:flutter/material.dart';

import '../extensions/context_x.dart';

/// Initials in a tinted circle.
///
/// The tint is derived from the name so the same person keeps the same color
/// across screens, which makes a long table easier to scan.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.initials,
    required this.seed,
    this.size = 34,
    super.key,
  });

  final String initials;

  /// Anything stable per person; the name or email both work.
  final String seed;

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.semantic.chart;
    final color = palette[seed.hashCode.abs() % palette.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: context.text.labelMedium?.copyWith(
          color: color,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
