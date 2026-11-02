import 'dart:typed_data';

import '../../../../core/utils/money.dart';

/// A product the admin is about to create.
///
/// The image travels as bytes, not a path: on web there is no file path to
/// hand to a multipart request, so the picker returns the contents directly.
class NewProduct {
  const NewProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageBytes,
    required this.imageFileName,
  });

  final String name;
  final String description;
  final Money price;
  final int categoryId;
  final Uint8List imageBytes;
  final String imageFileName;
}
