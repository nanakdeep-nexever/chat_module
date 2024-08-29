import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Screens/chatroom/messase_room.dart';
import 'package:chat_module/Screens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<Map<String, String>> items = [
    {"Email": "nanaks@gami.com", "lead": "N", "Name": "Nanak"},
    {"Email": "sukh1@gami.com", "lead": "S", "Name": "Sukh"},
    {"Email": "amita@gami.com", "lead": "A", "Name": "Amita"},
    {"Email": "tinal@gami.com", "lead": "T", "Name": "Tinal"},
    {"Email": "nandu@gami.com", "lead": "N", "Name": "Nandu"}
  ];

  @override
  Widget build(BuildContext context) {
    int Length_l = items.length;
    return Scaffold(
      appBar: AppBar(
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
          return ListView.builder(
            itemCount: Length_l,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item["Email"] ==
                  _firebaseAuth.currentUser?.email.toString()) {
                return ListTile(
                  title: Text(item["Name"] ?? ''),
                  leading: Text(item["lead"] ?? ''),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    String Name = item["Name"].toString();
                    String tosms = item["Email"].toString();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessagingPage(tosms),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(item["Name"] ?? ''),
                    leading: Text(item["lead"] ?? ''),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
