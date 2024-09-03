import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      if(userCredential != null){
        FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({'Fcm_token':NotificationHandler.token});
      }
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

      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "email": event.email,
        "name": event.name,
        "img": " ",
      });
      emit(
        AuthAuthenticated(user: userCredential.user),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _signout(SignOut event, Emitter<LoginState> emit) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'Fcm_token': ""}).then((value) {
      _firebaseAuth.signOut();
    });

    emit(AuthUnauthenticated());
  }
}
