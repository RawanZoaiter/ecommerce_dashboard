import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// A product image with a graceful fallback.
///
/// Falls back to the product's initial whenever the URL is empty or will not
/// load — offline, during a demo with no network, or for a product whose image
/// the API has not returned. A broken-image icon in every table row would make
/// the whole screen look faulty.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    required this.imageUrl,
    required this.name,
    this.size = 40,
    this.radius = AppRadius.sm,
    super.key,
  });

  final String imageUrl;
  final String name;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? _Fallback(name: name, size: size)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 180),
                // The same fallback while loading, so a slow or offline table
                // shows initials rather than a column of blank boxes.
                placeholder: (context, _) => _Fallback(name: name, size: size),
                errorWidget: (context, _, _) =>
                    _Fallback(name: name, size: size),
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();

    return ColoredBox(
      color: context.colors.primaryContainer,
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
            color: context.colors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
