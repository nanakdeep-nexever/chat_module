import 'dart:io';

import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Chat_Model/chatModel.dart';
import 'package:chat_module/Chat_Model/enums.dart';
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

  MessagingPage(this.tosms);

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final DateFormat _timeFormatter = DateFormat('HH:mm:ss');

  Future<void> _sendMessage(String? from) async {
    if (_messageController.text.isNotEmpty) {
      try {
        final message = Message(
          from: from!,
          to: widget.tosms,
          type: MessageType.text,
          content: _messageController.text,
          createdAt: Timestamp.now(),
        );

        await _firestore.collection('messages').add(message.toMap());
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: $e")),
        );
      }
    }
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
        SnackBar(content: Text("Camera permission denied")),
      );
      return;
    }

    try {
      final source =
          await _showImageSourceDialog(mediaType) ?? ImageSource.gallery;
      final pickedFile = mediaType == MediaType.image
          ? await picker.pickImage(source: source)
          : mediaType == MediaType.video
              ? await picker.pickVideo(source: source)
              : await picker.pickVideo(
                  source: source); // Handle document uploads if applicable

      if (pickedFile == null) {
        return;
      }

      File file = File(pickedFile.path);
      String fileName = "now_${DateTime.now().millisecondsSinceEpoch}";
      Reference storageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      final messageType = mediaType == MediaType.image
          ? MessageType.image
          : mediaType == MediaType.video
              ? MessageType.video
              : MessageType.document;

      final message = Message(
        from: from!,
        to: widget.tosms,
        type: messageType,
        content: downloadUrl,
        fileName: fileName,
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('messages').add(message.toMap());
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file: $e")),
      );
    }
  }

  Future<MediaType?> _showMediaSelectionDialog() async {
    return showDialog<MediaType>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Media Type'),
          actions: <Widget>[
            TextButton(
              child: Text('Image'),
              onPressed: () => Navigator.of(context).pop(MediaType.image),
            ),
            TextButton(
              child: Text('Video'),
              onPressed: () => Navigator.of(context).pop(MediaType.video),
            ),
            TextButton(
              child: Text('Document'),
              onPressed: () => Navigator.of(context).pop(MediaType.document),
            ),
            TextButton(
              child: Text('Cancel'),
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
          title: Text('Select Image Source'),
          actions: <Widget>[
            if (mediaType == MediaType.image) ...[
              TextButton(
                child: Text('Camera'),
                onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
            TextButton(
              child: Text('Gallery'),
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      final messageDoc =
          await _firestore.collection('messages').doc(messageId).get();
      final messageData = messageDoc.data() as Map<String, dynamic>;

      final fileName = messageData['fileName'] as String?;
      final fileUrl = messageData['url'] as String?;

      if (fileUrl != '' && fileName != '') {
        final storageRef =
            FirebaseStorage.instance.ref().child('uploads/$fileName');
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
              child: Text('Close'),
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
        title: Text('Messaging App'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<LoginBloc>().add(SignOut());
            },
            icon: Icon(Icons.ice_skating),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Logged out")),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                  stream: _firestore
                      .collection('messages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
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
          IconButton(
            icon: Icon(Icons.file_open),
            onPressed: () {
              String? from = _firebaseAuth.currentUser?.email;
              uploadMediaAndSaveReference(from);
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Enter your message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
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
        final message = Message.fromDocumentSnapshot(messages![index]);
        final messageId = messages[index].id;

        if ((_firebaseAuth.currentUser?.email == message.to ||
                _firebaseAuth.currentUser?.email == message.from) &&
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
                      title: Text('Delete Message'),
                      content:
                          Text('Are you sure you want to delete this message?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteMessage(messageId);
                          },
                          child: Text('Delete'),
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
                mainAxisAlignment: isSentByCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: isSentByCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.type == MessageType.text)
                        Text(message.content),
                      if (message.type == MessageType.image)
                        Image.network(
                          message.content,
                          height: 75,
                          width: 65,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error),
                        ),
                      if (message.type == MessageType.video)
                        SizedBox(
                          width: 100,
                          height: 80,
                          child: VideoPlayerWidget(url: message.content),
                        ),
                      if (message.type == MessageType.document)
                        Icon(Icons.description, size: 40),
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
        return SizedBox.shrink();
      },
    );
  }

  void _showVideoDialog(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.infinity,
            height: 300,
            child: VideoPlayerWidget(url: content),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
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

  VideoPlayerWidget({required this.url});

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
        : Center(child: CircularProgressIndicator());
  }
}
