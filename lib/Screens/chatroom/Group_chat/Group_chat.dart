import 'dart:async';

import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Chat_Model/utils/Group_model.dart';
import 'package:chat_module/Screens/chatroom/Group_chat/group_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../Chat_Model/enums.dart';
import '../../loginScreen.dart';

class Group_Chat extends StatefulWidget {
  String Groupid, Groupname;

  Group_Chat({super.key, required this.Groupid, required this.Groupname});

  @override
  State<Group_Chat> createState() => _Group_ChatState();
}

class _Group_ChatState extends State<Group_Chat> {
  TextEditingController _messageController = TextEditingController();
  Timer? _typingTimer;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firstore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  var maxScrollExtent = 0.0;
  bool isScroll = false;

  Future<void> _sendMessage(String? from) async {
    if (_messageController.text.isNotEmpty) {
      try {
        final message = Group_Model(
          from: from!,
          type: MessageType.text,
          content: _messageController.text,
          createdAt: Timestamp.now(),
        );

        await _firstore.collection('group').doc('${widget.Groupid}').collection('messages_group').add(message.toMap());
        // await updateLastM(widget.tosms, from, _messageController.text, '');
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: $e")),
        );
      }
    }
  }

  void _setTyping(bool status) async {
    try {
      await _firstore.collection('users').doc(_firebaseAuth.currentUser!.uid).update({'typing': status});
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> _userNames = {};
    Map<String, String> _userImages = {}; // Cache to store user profile images

    Future<String> _getUserImage(String email) async {
      if (_userImages.containsKey(email)) {
        return _userImages[email]!;
      } else {
        try {
          var userDoc =
              await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();

          if (userDoc.docs.isNotEmpty) {
            String imageUrl = userDoc.docs.first['img'] ?? ''; // Adjust field name if needed
            setState(() {
              _userImages[email] = imageUrl;
            });
            return imageUrl;
          } else {
            return '';
          }
        } catch (e) {
          print('Error fetching user image: $e');
          return '';
        }
      }
    }

    Future<String> getUserNameByEmail(String email) async {
      try {
        var userDoc =
            await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();

        if (userDoc.docs.isNotEmpty) {
          return userDoc.docs.first['name'] ?? 'Unknown'; // Adjust field name if needed
        } else {
          return 'Unknown';
        }
      } catch (e) {
        print('Error fetching user name: $e');
        return 'Unknown';
      }
    }

    Future<String> _getUserName(String email) async {
      if (_userNames.containsKey(email)) {
        return _userNames[email]!;
      } else {
        String name = await getUserNameByEmail(email);
        setState(() {
          _userNames[email] = name;
        });
        return name;
      }
    }

    Future<void> scrollToLastIndex() async {
      final position = _scrollController.position;
      _scrollController.position.maxScrollExtent;

      if (maxScrollExtent < _scrollController.position.maxScrollExtent) {
        maxScrollExtent = _scrollController.position.maxScrollExtent;
        if (position.hasPixels) {
          _scrollController.jumpTo(
            position.maxScrollExtent,
          );
        }
      }

      /*   await Future.delayed(const Duration(seconds: 2));

      if (isScroll == true) {
        return;
      }
      isScroll = true;

      if (position.hasPixels) {
        _scrollController.jumpTo(
          position.maxScrollExtent ?? 0,
        );
      }*/
    }

    initalData() {
      _firstore
          .collection('group')
          .doc(widget.Groupid)
          .collection('messages_group')
          .orderBy('createdAt', descending: false)
          .snapshots();
      scrollToLastIndex();
    }

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          child: Text(widget.Groupname),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupProfile(GRoupid: widget.Groupid),
              ),
            );
          },
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login_Screen()),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  initialData: initalData(),
                  stream: _firstore
                      .collection('group')
                      .doc(widget.Groupid)
                      .collection('messages_group')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final group = snapshot.data!.docs;

                    Map<DateTime, List<QueryDocumentSnapshot>> groupedMessages = {};
                    for (var messageDoc in group) {
                      final message = Group_Model.fromDocumentSnapshot(messageDoc);
                      final date = (message.createdAt).toDate();
                      final dateKey = DateTime(date.year, date.month, date.day);

                      if (!groupedMessages.containsKey(dateKey)) {
                        groupedMessages[dateKey] = [];
                      }

                      groupedMessages[dateKey]!.add(messageDoc);
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: groupedMessages.length,
                      itemBuilder: (context, dateIndex) {
                        final dateKey = groupedMessages.keys.elementAt(dateIndex);
                        final messagesForDate = groupedMessages[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text(
                                  DateFormat('d MMMM yyyy').format(dateKey),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ),
                            ...messagesForDate.map((messageDoc) {
                              final message = Group_Model.fromDocumentSnapshot(messageDoc);
                              final isSentByCurrentUser = FirebaseAuth.instance.currentUser!.email == message.from;

                              return FutureBuilder<Map<String, String>>(
                                future: Future.wait([
                                  _getUserName(message.from),
                                  _getUserImage(message.from),
                                ]).then((values) => {
                                      'name': values[0],
                                      'image': values[1],
                                    }),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.hasError) {
                                    return const Text("Unable to Fetch"); // Handle null data
                                  }

                                  final userName = userSnapshot.data?['name'] ?? "";
                                  final userImage = userSnapshot.data?['image'] ?? "";
                                  final formattedTime =
                                      DateFormat('hh:mm a').format((message.createdAt as Timestamp).toDate());

                                  return Align(
                                    alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final maxWidth = constraints.maxWidth / 1.5;

                                        return Container(
                                          constraints: BoxConstraints(maxWidth: maxWidth),
                                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                          decoration: BoxDecoration(
                                            color: isSentByCurrentUser ? Colors.blueAccent : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                isSentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                            children: [
                                              if (!isSentByCurrentUser)
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundImage:
                                                          userImage!.isNotEmpty ? NetworkImage(userImage) : null,
                                                      child: userImage.isEmpty ? const Icon(Icons.person) : null,
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      userName ?? "JOHN",
                                                      style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4),
                                              Text(
                                                isSentByCurrentUser ? '${message.content}' : message.content,
                                                textAlign: isSentByCurrentUser ? TextAlign.end : TextAlign.start,
                                                style: TextStyle(
                                                  color: isSentByCurrentUser ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formattedTime,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              MessegeType_bottom(),
            ],
          );
        },
      ),
    );
  }

  Padding MessegeType_bottom() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            maxLines: null,
            minLines: 1,
            controller: _messageController,
            onChanged: (string) {
              if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();

              _setTyping(true);

              _typingTimer = Timer(const Duration(seconds: 1), () {
                _setTyping(false);
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              hintText: 'Enter your message...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
              ),
              prefixIcon: IconButton(
                icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[600]),
                onPressed: () {},
              ),
              suffixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                      onPressed: () {
                        String? from = _firebaseAuth.currentUser?.email;
                        //uploadMediaAndSaveReference(from);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.grey[600]),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          )),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              String? from = _firebaseAuth.currentUser?.email;
              _sendMessage(from);
            },
          ),
        ],
      ),
    );
  }
}
