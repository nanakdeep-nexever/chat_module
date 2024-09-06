import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_module/Bloc/profile_bloc/profile_event.dart';
import 'package:chat_module/Bloc/profile_bloc/profile_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<UpdateProfile>(_onUpdateProfile);
    on<PickProfileImage>(_onPickProfileImage);
    on<FetchUserProfile>(_onFetchUserProfile);
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileUpdating());

    try {
      String? imageUrl;
      if (event.profileImage != null) {
        imageUrl = await _uploadImageToFirebase(event.profileImage!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'img': imageUrl,
      });

      emit(ProfileUpdated());
    } catch (e) {
      emit(ProfileUpdateFailed(e.toString()));
    }
  }

  Future<void> _onPickProfileImage(
      PickProfileImage event, Emitter<ProfileState> emit) async {
    final pickedImage = await ImagePicker().pickImage(source: event.source);
    if (pickedImage != null) {
      final file = File(pickedImage.path);
      emit(ProfileImagePicked(file));

      final imageUrl = await _uploadImageToFirebase(file);
      if (imageUrl != null) {
        emit(ProfileUpdatedWithImage(imageUrl));
      } else {
        emit(ProfileUpdateFailed('Image upload failed'));
      }
    } else {
      emit(ProfileImagePicked(null));
    }
  }

  Future<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<ProfileState> emit) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          emit(UserProfileLoaded(
            img: data['img'] ?? '',
          ));
        } else {
          emit(UserProfileLoadFailed('No data found'));
        }
      } else {
        emit(UserProfileLoadFailed('User document does not exist'));
      }
    } catch (e) {
      emit(UserProfileLoadFailed(e.toString()));
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${image.path.split('/').last}');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
