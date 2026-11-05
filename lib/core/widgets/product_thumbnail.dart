import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// A product image with a graceful fallback.
///
/// Loaded with [Image.network] and `webHtmlElementStrategy`, not with a
/// byte-fetching cache. On the web, fetching image bytes goes through the same
/// CORS check as any other request, and the API serves `/storage/...` without
/// an `Access-Control-Allow-Origin` header — so every product image was being
/// blocked by the browser and falling back to its initial. An `<img>` element
/// displays a cross-origin image without that header, which is exactly what a
/// plain web page does.
///
/// The initial is still drawn whenever the URL is empty or the image will not
/// load at all; a broken-image icon in every row would make the whole table
/// look faulty.
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
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // Falls back to an <img> element when the byte fetch is
                // refused, which is the cross-origin case above.
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                errorBuilder: (context, _, _) =>
                    _Fallback(name: name, size: size),
                frameBuilder: (context, child, frame, wasSynchronous) {
                  if (wasSynchronous || frame != null) return child;
                  // Hold the initial rather than a blank box while loading, so
                  // a slow table never shows a column of empty squares.
                  return _Fallback(name: name, size: size);
                },
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
