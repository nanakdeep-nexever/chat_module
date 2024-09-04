import 'dart:io';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {}

class ProfileUpdatedWithImage extends ProfileState {
  final String imageUrl;

  ProfileUpdatedWithImage(this.imageUrl);
}

class ProfileUpdateFailed extends ProfileState {
  final String error;

  ProfileUpdateFailed(this.error);
}

class ProfileImagePicked extends ProfileState {
  final File? profileImage;

  ProfileImagePicked(this.profileImage);
}

class UserProfileLoaded extends ProfileState {
  final String img;

  UserProfileLoaded({
    required this.img,
  });
}

class UserProfileLoadFailed extends ProfileState {
  final String error;

  UserProfileLoadFailed(this.error);
}
