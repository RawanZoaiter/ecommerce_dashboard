import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// A shimmering placeholder block.
///
/// Skeletons rather than a spinner: the page keeps its shape while loading, so
/// nothing jumps when the data lands.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height = 14,
    this.radius = AppRadius.sm,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.semantic.border,
      highlightColor: context.semantic.surfaceSunken,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.semantic.border,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Placeholder rows matching [AppTable]'s metrics, so a loading table is the
/// same height as the loaded one.
class TableSkeleton extends StatelessWidget {
  const TableSkeleton({this.rows = 8, this.columns = 5, super.key});

  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < rows; row++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                for (var column = 0; column < columns; column++)
                  Expanded(
                    flex: column == 0 ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.lg,
                      ),
                      child: SkeletonBox(
                        width: column == 0 ? null : 60,
                        height: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (row < rows - 1) const Divider(),
        ],
      ],
    );
  }
}
