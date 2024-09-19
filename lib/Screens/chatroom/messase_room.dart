import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Chat_Model/chatModel.dart';
import 'package:chat_module/Chat_Model/enums.dart';
import 'package:chat_module/Notification_handel/Notification_handle.dart';
import 'package:chat_module/Screens/chatroom/chats_profile.dart';
import 'package:chat_module/Screens/loginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_view/gif_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MessagingPage extends StatefulWidget {
  final String tosms;

  const MessagingPage(
    this.tosms, {
    super.key,
  });

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  final DateFormat _timeFormatter = DateFormat('HH:mm');
   String gifUrl = 'https://media.giphy.com/media/ICOgUNlE1I8tQ/giphy.gif';
  Timer? _typingTimer;
  bool _isEmojiVisible = false;

  void _onEmojiSelected(Emoji emoji) {
    _messageController.text += emoji.emoji;
  }



  updateLastM(String tosms, String from, String? msg, String? imgurl) async {
    String onScreenStatus = '';

    try {
      QuerySnapshot tosmasupdate = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: tosms)
          .get();
      QuerySnapshot fromsmsupdate = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: from)
          .get();

      for (QueryDocumentSnapshot doc in fromsmsupdate.docs) {
        doc.reference.update({'LastMessage': msg ?? ''});
      }

      for (QueryDocumentSnapshot doc in tosmasupdate.docs) {
        doc.reference.update({'LastMessage': msg ?? ''});
      }

      final userDoc = _firestore
          .collection('users')
          .where('email', isEqualTo: widget.tosms);
      final snapshot = await userDoc.get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        onScreenStatus = doc.get('on_screen');
      }
      print(
          "current user opencheck ${FirebaseAuth.instance.currentUser?.email}  and Reciver $onScreenStatus");
      if (onScreenStatus.toString() !=
          FirebaseAuth.instance.currentUser?.email.toString()) {
        QuerySnapshot FcmQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: tosms)
            .get();

        if (FcmQuery.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = FcmQuery.docs.first;
          String fcmToken = documentSnapshot.get('Fcm_token') as String;
          String message = msg ?? '';
          if (imgurl != null && imgurl.isNotEmpty) {
            message = 'Image';
          }
          NotificationHandler.sendNotification(
              FCM_token: fcmToken,
              title: "New Message",
              body: message,
              data: {
                'notificationType': "chat",
                'imageUrl': imgurl ?? '',
                "tosms": FirebaseAuth.instance.currentUser?.email
              });
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
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({'typing': status});
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }

  Future<void> updateMessages() async {
    final toSms = widget.tosms;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('from', isEqualTo: toSms)
          .get();

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
    final mediaType = await _showMediaSelectionDialog(context);

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
      final source =
          await _showImageSourceDialog(mediaType) ?? ImageSource.gallery;
      final pickedFile = mediaType == MediaType.image
          ? await picker.pickImage(source: source)
          : mediaType == MediaType.video
              ? await picker.pickVideo(source: source)
              : await picker.pickVideo(source: source);

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

  Future<void> openCamera(String? from) async {
    final picker = ImagePicker();

    final cameraStatus = await Permission.camera.request();

    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isGranted && storageStatus.isGranted) {
      try {
        const source = ImageSource.camera;
        final pickedFile = await picker.pickImage(source: source);

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

        const messageType = MessageType.image;

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
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Camera and storage permissions are required.")),
      );
    }
  }

  void setTyping(bool status) {
    _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({'typing': status});
  }

  Future<void> _updateOnScreenStatus(String status) async {
    try {
      final userDoc = _firestore
          .collection('users')
          .where('email', isEqualTo: _firebaseAuth.currentUser!.email);
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

  Future<MediaType?> _showMediaSelectionDialog(BuildContext context) async {
    return showModalBottomSheet<MediaType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Select Media Type',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Image'),
                onTap: () => Navigator.of(context).pop(MediaType.image),
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.green),
                title: const Text('Video'),
                onTap: () => Navigator.of(context).pop(MediaType.video),
              ),
              ListTile(
                leading:
                    const Icon(Icons.insert_drive_file, color: Colors.orange),
                title: const Text('Document'),
                onTap: () => Navigator.of(context).pop(MediaType.document),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<ImageSource?> _showImageSourceDialog(MediaType mediaType) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
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
        titleSpacing: -9.0,
        title: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where('email', isEqualTo: widget.tosms)
                .snapshots(),
            builder: (context, snapshot) {
              final users = snapshot.data?.docs;

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatsProfile(
                                img: users[0]['img'],
                                name: users[0]['name'],
                                email: users[0]['email'],
                              )));
                },
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: users![0]['img'] != null &&
                                  users[0]['img'].isNotEmpty
                              ? NetworkImage(users[0]['img'])
                              : const AssetImage('assets/placeholder.png')
                                  as ImageProvider,
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
                ),
              );
            }),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined),
          ),
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
                  stream: _firestore
                      .collection('messages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
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
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                  child: TextFormField(
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
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
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                    icon: Icon(_isEmojiVisible?Icons.keyboard_alt:Icons.emoji_emotions_outlined,
                        color: Colors.grey[600]),
                    onPressed: () {
                      setState(() {
                        _isEmojiVisible = !_isEmojiVisible;
                      });
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
                          onPressed: () {
                            String? from = _firebaseAuth.currentUser?.email;
                            openCamera(from);
                          },
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
          Offstage(
            offstage: !_isEmojiVisible,
            child: SizedBox(
              height: 256, // Adjust the height if needed
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _onEmojiSelected(emoji);
                },
                onBackspacePressed: () {
                  // Handle backspace if needed
                },
                textEditingController: _messageController,
                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28 *
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
                            ? 1.20
                            : 1.0),
                  ),
                  swapCategoryAndBottomBar: false,
                  skinToneConfig: const SkinToneConfig(),
                  categoryViewConfig: const CategoryViewConfig(),
                  bottomActionBarConfig: const BottomActionBarConfig(),
                  searchViewConfig: const SearchViewConfig(),
                ),
              ),
            ),
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
                      title: const Text('Delete Message'),
                      content: const Text(
                          'Are you sure you want to delete this message?'),
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
                        Container(
                          decoration: BoxDecoration(
                            color: isSentByCurrentUser
                                ? Colors.blue.shade200
                                : Colors.grey.shade200,
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.0,
                            ),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(22)),
                          ),
                          child: ClipRRect(
                            borderRadius: isSentByCurrentUser
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(20))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                message.content,
                                textAlign: isSentByCurrentUser
                                    ? TextAlign.end
                                    : TextAlign.start,
                                style: const TextStyle(
                                    color: Colors.black,
                                    wordSpacing: 2,
                                    letterSpacing: .5),
                                overflow: TextOverflow.values.last,
                              ),
                            ),
                          ),
                        ),
                      if (message.type == MessageType.image)
                        GestureDetector(onTap: (){
                          showImagePreview(context, message.content);
                        },
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // Background color
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                              border: Border.all(
                                color: Colors.white, // Border color
                                width: 2, // Border width
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3), // Shadow color
                                  spreadRadius: 2, // Shadow spread
                                  blurRadius: 4, // Shadow blur radius
                                  offset: Offset(0, 2), // Shadow offset
                                ),
                              ],
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  message.content,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red, // Error icon color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),


                      if (message.type == MessageType.video)
                        Container(

                          decoration: BoxDecoration(
                            color: Colors.black12, // Background color
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Shadow color
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: Offset(0, 3), // Position of the shadow
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white, // Border color
                              width: 2, // Border thickness
                            ),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: VideoPlayerWidget(url: message.content),
                            ),
                          ),
                        ),


                      if(message.type==MessageType.gif)
                        GifView.network(
                         message.content,
                          height: 200,
                          width: 200,
                        ),

                      if (message.type == MessageType.document)
                        const Icon(Icons.description, size: 40),
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
  void showImagePreview(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red, // Error icon color
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void _showVideoDialog(String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Add padding around the video
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // Ensure proper aspect ratio for the video
                    child: VideoPlayerWidget(url: content),
                  ),
                ),
              ),
              Positioned(
                top: 16.0,
                right: 16.0,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: 30.0, color: Colors.black),
                ),
              ),
            ],
          ),
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
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..addListener(() {
        if (_controller.value.hasError) {
          print('Video Player Error: ${_controller.value.errorDescription}');
        }
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      })
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});

          _controller.play();
          _controller.setLooping(true);
        }
      }).catchError((e) {
        print('Error initializing video: $e');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.hasError) {
      return Center(child: Text('Error loading video: ${_controller.value.errorDescription}'));
    }

    return _controller.value.isInitialized
        ? Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      /*  VideoProgressIndicator(_controller, allowScrubbing: true),*/
       /* IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayPause,
        ),*/
      ],
    )
        : const Center(child: CircularProgressIndicator());
  }
}


