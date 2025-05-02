import 'package:equatable/equatable.dart';

class Auth extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final bool? isAdmin;
  final String? accessToken;
  final String? refreshToken;
  final String? message;

  const Auth({
    this.id,
    this.name,
    this.email,
    this.isAdmin,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  @override
  List<Object?> get props => [id, name, email, isAdmin, accessToken, refreshToken, message];
}