import '../../../../core/error/result.dart';
import '../../../../core/mock/mock_seed.dart';
import '../../../../core/mock/mock_support.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

/// Sample-data implementation of [UserRepository]. There is no `GET /users`
/// on the server yet, so this is the only implementation that exists.
class MockUserRepository with MockSupport implements UserRepository {
  @override
  Future<Result<Paginated<User>>> users({
    int page = 1,
    int perPage = 15,
  }) async {
    await settle();

    final sorted = MockSeed.users.toList()
      ..sort((a, b) => b.id.compareTo(a.id));

    return Ok(paginate(sorted, page: page, perPage: perPage));
  }
}
