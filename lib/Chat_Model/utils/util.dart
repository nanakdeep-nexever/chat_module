import 'dart:io';

import 'package:chat_module/Chat_Model/chatModel.dart';
import 'package:chat_module/Chat_Model/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class MessageService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  MessageType _mapMediaTypeToMessageType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return MessageType.image;
      case MediaType.video:
        return MessageType.video;
      case MediaType.document:
        return MessageType.document;
      default:
        throw ArgumentError('Unknown MediaType: $mediaType');
    }
  }


  Future<void> updateMessagesStatus(String userEmail) async {
    try {
      // Query to find all messages where the recipient is the given user
      QuerySnapshot querySnapshot = await firestore
          .collection('messages')
          .where('to', isEqualTo: userEmail)
          .where('read', isEqualTo: false)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.update({'read': true});
      }

      print('Messages status updated successfully.');
    } catch (e) {
      print('Error updating messages status: $e');
    }
  }

  Future<void> sendMessage(String from, String to, String content) async {
    final message = Message_Model(
        from: from,
        to: to,
        type: MessageType.text,
        content: content,
        createdAt: Timestamp.now(),
        read: false);

    await firestore.collection('messages').add(message.toMap());
    await updateUserLastMessage(to, content);
  }

  Future<void> sendMediaMessage(String from, String to, MediaType types, String? downloadUrl) async {
    final messageType = _mapMediaTypeToMessageType(types);
    final message = Message_Model(
        from: from,
        to: to,
        type: messageType,
        content: downloadUrl ?? '',
        createdAt: Timestamp.now(),
        read: false);

    await firestore.collection('messages').add(message.toMap());
    await updateUserLastMessage(to, downloadUrl);
  }

  Future<String?> uploadMedia(File file, MediaType mediaType) async {
    try {
      final fileName = "${mediaType}_${DateTime.now().millisecondsSinceEpoch}";
      final storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading media: $e');
      return null;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final doc = firestore.collection('messages').doc(messageId);
    final message = await doc.get();
    final messageData = message.data() as Map<String, dynamic>;

    if (messageData['content'] != null && messageData['content'].isNotEmpty) {
      final storageRef = FirebaseStorage.instance.ref().child('uploads/${messageData['content']}');
      await storageRef.delete();
    }

    await doc.delete();
  }

  Future<void> updateUserLastMessage(String email, String? msg) async {
    try {
      final snapshot = await firestore.collection('users').where('email', isEqualTo: email).get();
      for (var doc in snapshot.docs) {
        await doc.reference.update({'LastMessage': msg ?? ''});
      }
    } catch (e) {
      print('Error updating user last message: $e');
    }
  }

  Future<void> updateTypingStatus(bool status) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId != null) {
      await firestore.collection('users').doc(userId).update({'typing': status});
    }
  }

  Future<void> updateOnScreenStatus(String status) async {
    final userEmail = firebaseAuth.currentUser?.email;
    if (userEmail != null) {
      final userDocs = await firestore.collection('users').where('email', isEqualTo: userEmail).get();
      for (var doc in userDocs.docs) {
        await doc.reference.update({'on_screen': status});
      }
    }
  }
}
