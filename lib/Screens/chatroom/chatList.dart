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

class _ChatHomeState extends State<ChatHome> with WidgetsBindingObserver{
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firstore =FirebaseFirestore.instance;

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void setStatus(bool status)  {
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
    } else{
      setStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(automaticallyImplyLeading: false,
        title: Text('Chat Home'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<LoginBloc>().add(SignOut());
            },
            icon: Icon(Icons.logout),
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
            stream: _firstore.collection('users').where("email", isNotEqualTo: _firebaseAuth.currentUser?.email).snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No users found.'));
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data();
                  final name = user['name'] as String?;
                  final email = user['email'] as String?;


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
                        title: Text(name ?? ''),
                        subtitle: user['LastMessage'].toString().isNotEmpty
                            ? user['typing'] == true
                            ? const Text('typing....')
                            : Text('${user['LastMessage']}')
                            : user['typing'] == true
                            ? const Text('typing....')
                            : null,
                        trailing: StreamBuilder<QuerySnapshot>(
                          stream: _firstore.collection('messages')
                              .where('read', isEqualTo: false)
                              .where('from', isEqualTo: email)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Loading...');
                            }
                            if (snapshot.hasError) {
                              return const Text('Error');
                            }
                            final reads = snapshot.data?.docs ?? [];
                            return Text(reads.isEmpty ? '' : '${reads.length}');
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
