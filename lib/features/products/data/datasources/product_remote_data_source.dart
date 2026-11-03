import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/remote_support.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/new_product.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._dio);

  final Dio _dio;

  /// `GET /categories` — the whole list, no pagination.
  Future<List<Category>> categories() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.categories,
    );
    return envelopeList(response).map(CategoryModel.fromJson).toList();
  }

  /// `GET /products`.
  ///
  /// `search` is accepted by the repository interface but not sent: the server
  /// has no `?search=` parameter yet, and filtering one fetched page locally
  /// would look like a search while silently ignoring the other pages.
  Future<Paginated<Product>> products({
    required int page,
    required int perPage,
    int? categoryId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.products,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'category_id': ?categoryId,
      },
    );
    return envelopePage(response, ProductModel.fromJson);
  }

  /// `GET /products/{id}` — the only endpoint carrying `available_quantity`.
  Future<Product> product(int id, {bool? inventoryReachable}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.product(id),
    );
    return ProductModel.fromJson(
      envelopeObject(response),
      inventoryReachable: inventoryReachable,
    );
  }

  /// `POST /products` as multipart, because it carries the image file.
  ///
  /// The content type is left for Dio to set: it has to include the multipart
  /// boundary, and a hand-written header would omit it (guide §5.10).
  Future<Product> create(NewProduct draft) async {
    final form = FormData.fromMap({
      'name': draft.name,
      'description': draft.description,
      'price': draft.price.apiValue,
      'category_id': draft.categoryId,
      'image': MultipartFile.fromBytes(
        draft.imageBytes,
        filename: draft.imageFileName,
      ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.products,
      data: form,
    );
    return ProductModel.fromJson(envelopeObject(response));
  }
}
