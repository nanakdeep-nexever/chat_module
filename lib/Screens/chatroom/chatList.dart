import 'dart:math';

import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Screens/chatroom/messase_room.dart';
import 'package:chat_module/Screens/loginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> with WidgetsBindingObserver {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firstore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  Future<bool> _isUserOnScreen(String email) async {
    final userDoc = _firstore
        .collection('users')
        .where('email', isEqualTo: email);
    final snapshot = await userDoc.get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return doc.get('on_screen') == _firebaseAuth.currentUser?.email;
    }
    return false;
  }

  void setStatus(bool status) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"status": status});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setStatus(true);
    } else {
      setStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chat Home'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<LoginBloc>().add(SignOut());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Login_Screen()),
            );
          }
        },
        builder: (context, state) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firstore
                .collection('users')
                .where("email",
                    isNotEqualTo: FirebaseAuth.instance.currentUser!.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data();
                  final name = user['name'] as String?;
                  final email = user['email'] as String?;
                  final img = user['img'] as String?;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessagingPage(email ?? ''),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                          radius: 25, // Adjust the radius as needed
                          backgroundImage: img != null && img.isNotEmpty
                              ? NetworkImage(img)
                              : null),
                      title: Text(
                        name ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      subtitle: FutureBuilder<bool>(
                        future: _isUserOnScreen(email!),
                        builder: (context, snapshot){
                          final isonscreen =snapshot.data ?? false;
                          final typing = user['typing'] ?? false;
                          print("typing  $typing    and isonscreen $typing");
                          return typing && isonscreen
                              ? const Text('typing....')
                              : (user['LastMessage'].toString().isNotEmpty
                              ? Text('${user['LastMessage']}')
                              : const SizedBox.shrink());
                        },
                      ),
                      trailing: StreamBuilder<QuerySnapshot>(
                        stream: _firstore
                            .collection('messages')
                            .where('read', isEqualTo: false)
                            .where('from', isEqualTo: email)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error');
                          }
                          final reads = snapshot.data?.docs ?? [];
                          return reads.isEmpty
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${reads.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
