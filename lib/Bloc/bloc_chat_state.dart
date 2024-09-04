import 'dart:io';

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

  const AuthAuthenticated({this.user});

  @override
  List<Object> get props => [user!];
}

class AuthUnauthenticated extends LoginState {}

class AuthError extends LoginState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class ImagePicked extends LoginState {
  final File image;

  const ImagePicked(this.image);

  @override
  List<Object> get props => [image];
}

class ImageUploaded extends LoginState {
  final String imageUrl;

  const ImageUploaded(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}
