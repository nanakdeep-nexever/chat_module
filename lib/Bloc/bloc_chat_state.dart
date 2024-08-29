import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

class AuthLoading extends LoginState {}

class AuthAuthenticated extends LoginState {
  final User? user;

  AuthAuthenticated({this.user});

  @override
  List<Object> get props => [user!];
}

class AuthUnauthenticated extends LoginState {}

class AuthError extends LoginState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}
