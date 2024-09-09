import 'dart:io';

import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? image;
  String _selectedValue = "Sleeping"; // Default selected value
  final List<String> _aboutOptions = [
    "Sleeping",
    "Eating",
    "Working",
    "Traveling",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading user details'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No user data found'));
            } else {
              var userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: userData['img'] != null
                                ? NetworkImage(userData['img'])
                                : const AssetImage(
                                        'assets/images/user_profile.jpg')
                                    as ImageProvider,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 40,
                        child: GestureDetector(
                          onTap: () {},
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.green,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt_outlined),
                              color: Colors.white,
                              onPressed: () {
                                _showImagePickerOptions(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.person_2_outlined, size: 20),
                    title: const Text(
                      " Name",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      userData['name'] ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        _showEditNameModal(context, userData['name'] ?? '');
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, size: 20),
                    title: const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      _selectedValue, // Display the selected value
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    trailing: DropdownButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedValue = newValue!;
                        });
                      },
                      items: _aboutOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined, size: 20),
                    title: const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      userData['email'] ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                    thickness: 0.1,
                  ),
                   ListTile(
                    onTap: (){
                      context.read<LoginBloc>().add(SignOut());
                    },
                    leading: Icon(Icons.logout, size: 20),
                    title:const Text(
                      "LogOut",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 90,
                  ),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "version 1.0.1",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          "Powered by - Nanak & Akash",
                          style: TextStyle(fontSize: 8, color: Colors.grey),
                        )
                      ],
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _showEditNameModal(BuildContext context, String currentName) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);

    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit your name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          "name": nameController.text.trim().toString()
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      image = File(pickedImage.path);
      setState(() {});
      uploadImageToFirebase(image!);
    }
  }

  Future<void> uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${imageFile.path.split('/').last}');

      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print("Download URL: $downloadUrl");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'img': downloadUrl});

      print("Image URL updated successfully in Firestore.");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
