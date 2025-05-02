import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final bool? isAdmin;
  final String? accessToken;
  final String? refreshToken;
  final String? message;

  const AuthModel({
    this.id,
    this.name,
    this.email,
    this.isAdmin,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id']?.toString(),
      name: json['name'],
      email: json['email'],
      isAdmin: json['isAdmin'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [id, name, email, isAdmin, accessToken, refreshToken, message];
}