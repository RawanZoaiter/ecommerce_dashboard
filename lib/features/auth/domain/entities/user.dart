import 'package:equatable/equatable.dart';

enum UserRole {
  customer,
  admin;

  static UserRole fromApi(String? value) =>
      value == 'admin' ? UserRole.admin : UserRole.customer;

  String get apiValue => name;

  bool get isAdmin => this == UserRole.admin;
}

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime? createdAt;

  /// First letter(s) for the avatar, taken from the name and falling back to
  /// the email so the circle is never blank.
  String get initials {
    final source = name.trim().isNotEmpty ? name.trim() : email.trim();
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, email, role, createdAt];
}
