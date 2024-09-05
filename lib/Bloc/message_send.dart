import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../Screens/chatroom/messase_room.dart';
import '../main.dart';

class MessagingBloc {
  final _messageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  MessagingBloc() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // _setupBackground();
  }
  void addstream(RemoteMessage message) {
    _messageStreamController.add(message);
  }

  // Top-level or static function for background message handling
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Background message handling
    print("Handling a background message: ${message.messageId}");
  }

  void handleMessage(RemoteMessage message) async {
    if (message.data.isEmpty) return;
    if (message.data['tosms'] != null || message.data["tosms"] != "") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => MessagingPage(message.data['tosms']),
        ),
      );
    }
  }

  void dispose() {
    _messageStreamController.close();
  }
}
