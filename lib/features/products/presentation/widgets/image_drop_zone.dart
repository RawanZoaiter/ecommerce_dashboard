import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/new_product_cubit.dart';

/// Image picker with a preview.
///
/// Shows the chosen file immediately: an admin should see what they picked
/// before sending it, not discover a wrong image once the product is live.
class ImageDropZone extends StatelessWidget {
  const ImageDropZone({
    required this.onPick,
    required this.onRemove,
    this.bytes,
    this.fileName,
    this.rejection,
    super.key,
  });

  final VoidCallback onPick;
  final VoidCallback onRemove;
  final Uint8List? bytes;
  final String? fileName;
  final ImageRejection? rejection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final rejectionMessage = switch (rejection) {
      ImageRejection.type => l10n.productFormErrorImageType,
      ImageRejection.size => l10n.productFormErrorImageSize,
      null => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (bytes == null)
          _Placeholder(onPick: onPick, hasError: rejection != null)
        else
          _Preview(
            bytes: bytes!,
            fileName: fileName ?? '',
            onPick: onPick,
            onRemove: onRemove,
          ),
        if (rejectionMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            rejectionMessage,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.onPick, required this.hasError});

  final VoidCallback onPick;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? context.colors.error
        : context.semantic.borderStrong;

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: DottedBorderBox(
        color: borderColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 34,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.productFormImagePick,
                style: context.text.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.productFormImageRules,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.bytes,
    required this.fileName,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List bytes;
  final String fileName;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final sizeInKb = (bytes.lengthInBytes / 1024).round();

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.memory(bytes, width: 96, height: 96, fit: BoxFit.cover),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                style: context.text.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '$sizeInKb KB',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: onPick,
                    child: Text(context.l10n.productFormImageReplace),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: onRemove,
                    child: Text(context.l10n.productFormImageRemove),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A dashed outline. Flutter has no dashed border, and pulling in a package
/// for one rectangle is not worth it, so it is painted here.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({required this.child, required this.color, super.key});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(color: color),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const dash = 6.0;
    const gap = 4.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.md),
    );

    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
