import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'bloc_chat_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitial()) {
    on<SignInWithEmail>(Singnup_pro);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<SignOut>(_signout);
  }

  FutureOr<void> Singnup_pro(
      SignInWithEmail event, Emitter<LoginState> emit) async {
    try {
      emit(AuthLoading());
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: userCredential.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _onSignUpWithEmail(
      SignUpWithEmail event, Emitter<LoginState> emit) async {
    try {
      emit(AuthLoading());
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(
        AuthAuthenticated(user: userCredential.user),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _signout(SignOut event, Emitter<LoginState> emit) {
    _firebaseAuth.signOut();
    emit(AuthUnauthenticated());
  }
}
