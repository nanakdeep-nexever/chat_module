part of 'bloc_chat_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class SignInWithEmail extends LoginEvent {
  final String email;
  final String password;

  SignInWithEmail({required this.email, required this.password});
}

class SignUpWithEmail extends LoginEvent {
  final String email;
  final String password;

  SignUpWithEmail({required this.email, required this.password});
}

class SignOut extends LoginEvent {}
