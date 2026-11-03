import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/user.dart';

/// Builds a [User] from the API's user object (guide §5.6).
abstract final class UserModel {
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromApi(json['role'] as String?),
      createdAt: DateFormatter.tryParse(json['created_at'] as String?),
    );
  }
}
