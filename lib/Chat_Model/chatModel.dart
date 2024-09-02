import 'package:chat_module/Chat_Model/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message_Model {
  final String from;
  final String to;
  final MessageType type;
  final String content;
  final String fileName;
  final bool read;
  final Timestamp createdAt;

  Message_Model({
    required this.from,
    required this.to,
    required this.type,
    required this.content,
    this.fileName = "",
    required this.read,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'type': type.toString(),
      'content': content,
      'fileName': fileName,
      'read': read,
      'createdAt': createdAt,
    };
  }

  factory Message_Model.fromMap(Map<String, dynamic> map) {
    return Message_Model(
      from: map['from'] as String? ?? '',
      to: map['to'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) =>
            e.toString() ==
            (map['type'] as String? ?? MessageType.text.toString()),
        orElse: () => MessageType.text,
      ),
      content: map['content'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      fileName: map['fileName'] as String? ?? '',
      read: map['read'] as bool? ?? false
    );
  }

  factory Message_Model.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Message_Model.fromMap(data);
  }
}
