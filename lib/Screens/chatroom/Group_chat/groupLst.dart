import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Screens/chatroom/Group_chat/Group_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../loginScreen.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  bool Nogroup = true;
  FirebaseFirestore _firstore = FirebaseFirestore.instance;
  FirebaseAuth _fireauth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: Nogroup
          ? null
          : FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
      body: BlocConsumer<LoginBloc, LoginState>(listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Login_Screen()),
          );
        }
      }, builder: (context, state) {

        return StreamBuilder(
          stream: _firstore
              .collection('group')
              .where("mambers", arrayContains: _fireauth.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {

              Nogroup = false;
              return const Center(child: Text('No Group found.'));
            }


            final groupList = snapshot.data!.docs;

            return ListView.builder(

              itemCount: groupList.length,
              itemBuilder: (context, index) {
                Nogroup =true;
                final group = groupList[index];
                return ListTile(
                  onTap: () {

                    onTapgroup(group['id'].toString(),group['name']);
                  },
                  title: Text(group['name']),
                );
              },
            );
          },
        );

      }),
    );
  }

  void onTapgroup(String Group_id ,String Group_name) {
    print("list $Group_id");
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Group_Chat(Groupid: Group_id, Groupname: Group_name,),),);
  }
}
