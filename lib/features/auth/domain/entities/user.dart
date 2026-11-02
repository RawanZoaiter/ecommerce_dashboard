import 'package:equatable/equatable.dart';

import '../../../../core/utils/initials.dart';

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

  /// Falls back to the email so the avatar is never blank.
  String get initials => initialsFrom(name.trim().isNotEmpty ? name : email);

  @override
  List<Object?> get props => [id, name, email, role, createdAt];
}
