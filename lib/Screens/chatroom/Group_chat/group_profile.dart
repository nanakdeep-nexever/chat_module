

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupProfile extends StatefulWidget {
  String GRoupid;
   GroupProfile({super.key,required this.GRoupid});

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  FirebaseFirestore _firestore =FirebaseFirestore.instance;
  List<dynamic> Mambers=[];

  Future<void> _fetchData() async {
    try {

      DocumentSnapshot docSnapshot = await _firestore
          .collection('group')
          .doc(widget.GRoupid)
          .get();

      if (docSnapshot.exists) {

        List<dynamic> nestedArrays = docSnapshot.get('mambers') as List<dynamic>;


        setState(() {
          Mambers = nestedArrays;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Group Profile"),
    ),
      body: ListView.builder(
        itemCount: Mambers.length ?? 0,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(Mambers[index]),
          );
        },
      ),
    );
  }
}
