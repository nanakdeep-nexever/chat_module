import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

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

  // Uncomment and complete this method if you need to handle messages on app launch
  /*
  void _setupBackground() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _messageStreamController.add(initialMessage);
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['Type'] == "data_person") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Testcase1Page(message.data),
        ),
      );
    } else if (message.data['Type'] == "data_testcase2") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KeysonlyPage(message.data),
        ),
      );
    }
    _messageStreamController.add(message);
  }
  */

  void dispose() {
    _messageStreamController.close();
  }
}