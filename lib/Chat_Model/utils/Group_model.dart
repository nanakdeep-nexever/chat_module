
import 'package:chat_module/Chat_Model/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Group_Model {
  final String from;

  final MessageType type;
  final String content;
  final String fileName;

  final Timestamp createdAt;

  Group_Model({
    required this.from,
    required this.type,
    required this.content,
    this.fileName = "",

    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'type': type.toString(),
      'content': content,
      'fileName': fileName,
      'createdAt': createdAt,
    };
  }

  factory Group_Model.fromMap(Map<String, dynamic> map) {
    return Group_Model(
        from: map['from'] as String? ?? '',

        type: MessageType.values.firstWhere(
              (e) =>
          e.toString() ==
              (map['type'] as String? ?? MessageType.text.toString()),
          orElse: () => MessageType.text,
        ),
        content: map['content'] as String? ?? '',
        createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
        fileName: map['fileName'] as String? ?? '',

    );
  }

  factory Group_Model.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Group_Model.fromMap(data);
  }
}




class UserModel {
  final String? fcmToken;
  final String? lastMessage;
  final String? email;
  final String? img;
  final String? name;
  final String? onScreen;
  final bool? status;
  final bool? typing;
  final int? unread;

  UserModel({
    this.fcmToken,
    this.lastMessage,
    this.email,
    this.img,
    this.name,
    this.onScreen,
    this.status,
    this.typing,
    this.unread,
  });


  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      fcmToken: data['fcmToken'] as String?,
      lastMessage: data['lastMessage'] as String?,
      email: data['email'] as String?,
      img: data['img'] as String?,
      name: data['name'] as String?,
      onScreen: data['onScreen'] as String?,
      status: data['status'] as bool?,
      typing: data['typing'] as bool?,
      unread: data['unread'] as int?,
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'fcmToken': fcmToken,
      'lastMessage': lastMessage,
      'email': email,
      'img': img,
      'name': name,
      'onScreen': onScreen,
      'status': status,
      'typing': typing,
      'unread': unread,
    };
  }

  @override
  String toString() {
    return 'UserModel(fcmToken: $fcmToken, lastMessage: $lastMessage, email: $email, img: $img, name: $name, onScreen: $onScreen, status: $status, typing: $typing, unread: $unread)';
  }
}
