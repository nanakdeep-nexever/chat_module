import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../Notification_handel/Notification_handle.dart';

part 'bloc_chat_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitial()) {
    on<SignInWithEmail>(_signInWithEmail);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<SignOut>(_signOut);
    on<PickImage>(_pickImage);
    on<UploadImage>(_uploadImage);
  }

  Future<void> _signInWithEmail(
      SignInWithEmail event, Emitter<LoginState> emit) async {
    try {
      emit(AuthLoading());
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'Fcm_token': NotificationHandler.token, 'status': true});
      emit(AuthAuthenticated(user: userCredential.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithEmail(
      SignUpWithEmail event, Emitter<LoginState> emit) async {
    try {
      emit(AuthLoading());
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "email": event.email,
        "name": event.name,
        "img": "",
        "status": true,
        "on_screen": false,
        "unread": 0,
        "typing": false,
        "Fcm_token": NotificationHandler.token,
        "LastMessage": ""
      });

      emit(AuthAuthenticated(user: userCredential.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _signOut(SignOut event, Emitter<LoginState> emit) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'Fcm_token': "", 'on_screen': "", 'status': false});
        await _firebaseAuth.signOut();
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _pickImage(PickImage event, Emitter<LoginState> emit) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        emit(ImagePicked(File(pickedFile.path)));
      } else {
        emit(const AuthError('No image selected'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _uploadImage(UploadImage event, Emitter<LoginState> emit) async {
    try {
      emit(AuthLoading());

      if (event.imagePath.isEmpty) {
        emit(const AuthError('No image path provided'));
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${event.imagePath.split('/').last}');

      final uploadTask = storageRef.putFile(File(event.imagePath));

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print(" ---download url--$downloadUrl");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'img': downloadUrl});

      emit(ImageUploaded(downloadUrl));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
