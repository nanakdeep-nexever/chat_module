import 'dart:async';
import 'dart:io';

import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Chat_Model/chatModel.dart';
import 'package:chat_module/Chat_Model/enums.dart';
import 'package:chat_module/Notification_handel/Notification_handle.dart';
import 'package:chat_module/Screens/chatroom/chats_profile.dart';
import 'package:chat_module/Screens/loginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MessagingPage extends StatefulWidget {
  final String tosms;

  const MessagingPage(this.tosms, {super.key});

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  Timer? _typingTimer;

  updateLastM(String tosms, String from, String? msg, String? imgurl) async {
    String onScreenStatus = '';

    try {
      QuerySnapshot tosmasupdate =
          await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: tosms).get();
      QuerySnapshot fromsmsupdate =
          await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: from).get();

      for (QueryDocumentSnapshot doc in fromsmsupdate.docs) {
        doc.reference.update({'LastMessage': msg ?? ''});
      }

      for (QueryDocumentSnapshot doc in tosmasupdate.docs) {
        doc.reference.update({'LastMessage': msg ?? ''});
      }

      final userDoc = _firestore.collection('users').where('email', isEqualTo: widget.tosms);
      final snapshot = await userDoc.get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        onScreenStatus = doc.get('on_screen');
      }
      print("current user opencheck ${FirebaseAuth.instance.currentUser?.email}  and Reciver $onScreenStatus");
      if (onScreenStatus.toString() != FirebaseAuth.instance.currentUser?.email.toString()) {
        QuerySnapshot FcmQuery =
            await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: tosms).get();

        if (FcmQuery.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = FcmQuery.docs.first;
          String fcmToken = documentSnapshot.get('Fcm_token') as String;
          NotificationHandler.sendNotification(
              FCM_token: fcmToken, title: "New Message", body: "$msg", data: {'imageUrl': imgurl ?? ''});
        }
      }

      print('Documents updated successfully');
    } catch (e) {
      print('Error updating documents: $e');
    }
  }

  Future<void> _sendMessage(String? from) async {
    if (_messageController.text.isNotEmpty) {
      try {
        final message = Message_Model(
            from: from!,
            to: widget.tosms,
            type: MessageType.text,
            content: _messageController.text,
            createdAt: Timestamp.now(),
            read: false);

        await _firestore.collection('messages').add(message.toMap());
        await updateLastM(widget.tosms, from, _messageController.text, '');
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
      await _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).update({'typing': status});
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }

  Future<void> updateMessages() async {
    final toSms = widget.tosms;

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('messages').where('from', isEqualTo: toSms).get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        doc.reference.update({'read': true});
      }

      print('Documents updated successfully');
    } catch (e) {
      print('Error updating documents: $e');
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _updateOnScreenStatus("");
    super.dispose();
  }

  Future<void> uploadMediaAndSaveReference(String? from) async {
    final picker = ImagePicker();
    final mediaType = await _showMediaSelectionDialog();

    if (mediaType == null) {
      return;
    }

    final status = await Permission.camera.request();
    if (mediaType == MediaType.image && !status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
      return;
    }

    try {
      final source = await _showImageSourceDialog(mediaType) ?? ImageSource.gallery;
      final pickedFile = mediaType == MediaType.image
          ? await picker.pickImage(source: source)
          : mediaType == MediaType.video
              ? await picker.pickVideo(source: source)
              : await picker.pickVideo(source: source); // Handle document uploads if applicable

      if (pickedFile == null) {
        return;
      }

      File file = File(pickedFile.path);
      String fileName = "now_${DateTime.now().millisecondsSinceEpoch}";
      Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      final messageType = mediaType == MediaType.image
          ? MessageType.image
          : mediaType == MediaType.video
              ? MessageType.video
              : MessageType.document;

      final message = Message_Model(
          from: from!,
          to: widget.tosms,
          type: messageType,
          content: downloadUrl,
          fileName: fileName,
          createdAt: Timestamp.now(),
          read: false);

      await _firestore.collection('messages').add(message.toMap());
      updateLastM(widget.tosms, from.toString(), 'image', downloadUrl);
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file: $e")),
      );
    }
  }

  Future<void> _updateOnScreenStatus(String status) async {
    try {
      final userDoc = _firestore.collection('users').where('email', isEqualTo: _firebaseAuth.currentUser!.email);
      final snapshot = await userDoc.get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'on_screen': status});
      }
    } catch (e) {
      print('Error updating on_screen status: $e');
    }
  }

  @override
  void initState() {
    updateMessages();
    _updateOnScreenStatus(widget.tosms);
    super.initState();
  }

  Future<MediaType?> _showMediaSelectionDialog() async {
    return showDialog<MediaType>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Media Type'),
          actions: <Widget>[
            TextButton(
              child: const Text('Image'),
              onPressed: () => Navigator.of(context).pop(MediaType.image),
            ),
            TextButton(
              child: const Text('Video'),
              onPressed: () => Navigator.of(context).pop(MediaType.video),
            ),
            TextButton(
              child: const Text('Document'),
              onPressed: () => Navigator.of(context).pop(MediaType.document),
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<ImageSource?> _showImageSourceDialog(MediaType mediaType) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        // Only show the camera option if mediaType is Image
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: <Widget>[
            if (mediaType == MediaType.image) ...[
              TextButton(
                child: const Text('Camera'),
                onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
            TextButton(
              child: const Text('Gallery'),
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      final messageDoc = await _firestore.collection('messages').doc(messageId).get();
      final messageData = messageDoc.data() as Map<String, dynamic>;

      final fileName = messageData['fileName'] as String?;
      final fileUrl = messageData['url'] as String?;

      if (fileUrl != '' && fileName != '') {
        final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
        await storageRef.delete();
      }

      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete message: $e")),
      );
    }
  }

  void _showDocumentDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.infinity,
            height: 400,
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(url)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").where('email', isEqualTo: widget.tosms).snapshots(),
            builder: (context, snapshot) {
              final users = snapshot.data?.docs;

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              return Row(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatsProfile(img: users[0]['img'], name: users[0]['name'], email: users[0]['email']),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: users![0]['img'] != null && users[0]['img'].isNotEmpty
                              ? NetworkImage(users[0]['img'])
                              : const AssetImage('assets/placeholder.png') as ImageProvider,
                        ),
                      ),
                      if (users[0]['status'])
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(users[0]['name'].toString()),
                      if (users[0]['status']) ...[
                        if (users[0]['typing']) ...[
                          const Text(
                            'typing...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'online',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              );
            }),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Login_Screen()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out")),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                  stream: _firestore.collection('messages').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final messages = snapshot.data?.docs;
                    return buildListView(messages);
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
                onPressed: () {
                  // Handle emoji icon press
                },
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
                        uploadMediaAndSaveReference(from);
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

  ListView buildListView(List<QueryDocumentSnapshot<Object?>>? messages) {
    return ListView.builder(
      reverse: true,
      itemCount: messages?.length ?? 0,
      itemBuilder: (context, index) {
        final message = Message_Model.fromDocumentSnapshot(messages![index]);
        final messageId = messages[index].id;

        if ((_firebaseAuth.currentUser?.email == message.to || _firebaseAuth.currentUser?.email == message.from) &&
            (widget.tosms == message.to || widget.tosms == message.from)) {
          final isSentByCurrentUser = widget.tosms == message.to;

          return GestureDetector(
            onTap: () {
              if (message.type == MessageType.video) {
                _showVideoDialog(message.content);
              } else if (message.type == MessageType.document) {
                _showDocumentDialog(message.content);
              }
            },
            onLongPress: () {
              if (isSentByCurrentUser) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Message'),
                      content: const Text('Are you sure you want to delete this message?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteMessage(messageId);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: isSentByCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: isSentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (message.type == MessageType.text)
                        Container(
                          decoration: BoxDecoration(
                            color: isSentByCurrentUser ? Colors.blue.shade200 : Colors.grey.shade200,
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.0,
                            ),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(22)),
                          ),
                          child: ClipRRect(
                            borderRadius: isSentByCurrentUser
                                ? const BorderRadius.only(topLeft: Radius.circular(20))
                                : const BorderRadius.only(topRight: Radius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                message.content,
                                textAlign: isSentByCurrentUser ? TextAlign.end : TextAlign.start,
                                style: const TextStyle(color: Colors.black, wordSpacing: 2, letterSpacing: .5),
                                overflow: TextOverflow.values.last,
                              ),
                            ),
                          ),
                        ),
                      if (message.type == MessageType.image)
                        Image.network(
                          message.content,
                          height: 75,
                          width: 65,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                      if (message.type == MessageType.video)
                        SizedBox(
                          width: 100,
                          height: 80,
                          child: VideoPlayerWidget(url: message.content),
                        ),
                      if (message.type == MessageType.document) const Icon(Icons.description, size: 40),
                      Text(
                        _timeFormatter.format(message.createdAt.toDate()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showVideoDialog(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.infinity,
            height: 300,
            child: VideoPlayerWidget(url: content),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..addListener(() {
        if (_controller.value.hasError) {
          print('Video Player Error: ${_controller.value.errorDescription}');
        }
      })
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
        _controller.pause();
      }).catchError((e) {
        print('Error initializing video: $e');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
