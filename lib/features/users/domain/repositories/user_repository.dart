import '../../../../core/error/result.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/domain/entities/user.dart';

abstract interface class UserRepository {
  /// Maps onto `GET /users` for admins, which the guide lists as one of the
  /// four modules but does not yet document an endpoint for.
  Future<Result<Paginated<User>>> users({int page, int perPage});
}
