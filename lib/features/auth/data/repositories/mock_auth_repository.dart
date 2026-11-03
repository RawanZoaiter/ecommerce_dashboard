import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/mock/mock_seed.dart';
import '../../../../core/mock/mock_support.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Sample-data implementation of [AuthRepository].
///
/// Accepts the dev admin credentials from the guide and rejects everything
/// else with the same [UnauthenticatedFailure] a real 401 maps to, so the
/// login screen's error path is real. Signing in as a customer is possible on
/// purpose — the dashboard has to refuse non-admins, and that cannot be tested
/// if no customer can ever log in.
class MockAuthRepository with MockSupport implements AuthRepository {
  static const _adminEmail = 'admin@example.com';
  static const _adminPassword = '123456789';
  static const _customerPassword = 'Secret123';

  User? _session = AppConfig.mockSignedIn ? MockSeed.admin : null;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    await settle();

    final normalized = email.trim().toLowerCase();

    if (normalized == _adminEmail && password == _adminPassword) {
      _session = MockSeed.admin;
      return Ok(MockSeed.admin);
    }

    final customer = MockSeed.users
        .where(
          (user) =>
              user.email.toLowerCase() == normalized && !user.role.isAdmin,
        )
        .firstOrNull;

    if (customer != null && password == _customerPassword) {
      _session = customer;
      return Ok(customer);
    }

    return const Err(
      UnauthenticatedFailure(debugMessage: 'Invalid credentials.'),
    );
  }

  @override
  Future<Result<User>> currentUser() async {
    await settle();
    final session = _session;
    return session == null
        ? const Err(UnauthenticatedFailure(debugMessage: 'Unauthenticated.'))
        : Ok(session);
  }

  @override
  Future<Result<void>> logout() async {
    await settle();
    _session = null;
    return const Ok(null);
  }

  @override
  Future<bool> hasStoredSession() async => _session != null;
}
