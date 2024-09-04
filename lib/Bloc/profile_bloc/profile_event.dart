import 'dart:io';

import 'package:image_picker/image_picker.dart';

abstract class ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final File? profileImage;

  UpdateProfile({
    this.profileImage,
  });
}

class PickProfileImage extends ProfileEvent {
  final ImageSource source;

  PickProfileImage({required this.source});
}

class FetchUserProfile extends ProfileEvent {}
