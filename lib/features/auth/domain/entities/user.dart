import '../../../shared/domain/entities/base_entity.dart';

class UserModel extends BaseEntity {
  final String username;
  final String password;
  final String email;
  final String role; // 'user' or 'admin'

  const UserModel({
    required this.username,
    required this.password,
    required this.email,
    this.role = 'user',
    String? id,
  }) : super(id: id);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      password: json['password'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      id: json['id'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'role': role,
      'id': id,
    };
  }
}
