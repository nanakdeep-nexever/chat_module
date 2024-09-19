import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../Screens/chatroom/messase_room.dart';
import '../main.dart';
import 'Notification_handle.dart';

class NotificationService {
  NotificationService._();
  static NotificationService get instance => NotificationService._();
  factory NotificationService() {
    print('NotificationService constructor isInitialized : $isInitialized');
    return instance;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool isInitialized = false;

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_test');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: null);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );
    isInitialized = true;
    flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((details) {
      if (details != null &&
          details.notificationResponse != null &&
          details.notificationResponse?.notificationResponseType ==
              NotificationResponseType.selectedNotification) {
        handleMessage(
            jsonDecode(details.notificationResponse!.payload ?? '{}'));
      }
    });
  }

  Future<void> initMessaging() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('Permission granted: ${settings.authorizationStatus}');
    FirebaseMessaging.onMessage.listen(showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    NotificationHandler.updateToken();
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) async {
    print(
        "onDidReceiveNotificationResponse payload----chat---${response.payload}");

    var payload = jsonDecode(response.payload ?? '{}') as Map<String, dynamic>;
      print("----payload data---$payload");

    if (response.notificationResponseType ==
        NotificationResponseType.selectedNotification) {
      print("Notification tapped without inline reply.");
      handleMessage(payload);
    }



    /*else if (response.notificationResponseType ==
            NotificationResponseType.selectedNotificationAction &&
        response.actionId == 'reply_action') {
      String replyText = response.input ?? '';
      print('User replied: $replyText');

      var updatedPayload = Map<String, dynamic>.from(payload);
      updatedPayload['reply'] = replyText;

      handleMessage(
        updatedPayload,
      );
    }*/
     if (response.notificationResponseType ==
        NotificationResponseType.selectedNotificationAction &&
        response.actionId == 'reply_action') {

      String replyText = response.input ?? '';
      print('User replied: $replyText');


      handleReplyAction(payload, replyText);
    }
  }

  void handleForegroundMessage(RemoteMessage message) {
    handleMessage(message.data);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    if (url.isNotEmpty) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    }
    return "";
  }

  Future<void> showNotification(RemoteMessage message) async {
    if (!isInitialized) await NotificationService.instance.initialize();
    final String? imgUrl = message.data['imageUrl'] ??
        'https://www.pushengage.com/wp-content/uploads/2023/06/In-App-Notification-Examples.png';
    String? imagePath;
    BigPictureStyleInformation? bigPictureStyleInformation;

    if (imgUrl != null && imgUrl.isNotEmpty) {
      imagePath = await _downloadAndSaveFile(imgUrl, 'notification_image.jpg');
      if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
        bigPictureStyleInformation =
            BigPictureStyleInformation(FilePathAndroidBitmap(imagePath));

      }
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      // largeIcon: imagePath != null ? FilePathAndroidBitmap(imagePath) : null,
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('sounds'),
      styleInformation: bigPictureStyleInformation,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'reply_action',
          'Reply',
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(
              label: 'Type your message',
              allowFreeFormInput: true,
            )
          ],
        ),
      ],
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: null,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  void handleMessage(Map<String, dynamic> data) async {
    if (data.isEmpty) return;

    if (data['tosms'] != null || data["tosms"] != "") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => MessagingPage(data['tosms']),
        ),
      );
    }
  }



  void handleReplyAction(Map<String, dynamic> payload, String replyText) {

    var updatedPayload = Map<String, dynamic>.from(payload);
    updatedPayload['reply'] = replyText;


    print('Processing user reply: $replyText');
    print('Updated payload: $updatedPayload');


    processPayload(updatedPayload);
  }

  void processPayload(Map<String, dynamic> data) {
    if (data.isEmpty) return;


    if (data.containsKey('reply')) {
      print('Reply received in payload: ${data['reply']}');

    }

    if (data['tosms'] != null && data['tosms'].isNotEmpty) {
      // Navigate to the messaging page
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => MessagingPage(data['tosms']),
        ),
      );
    }
  }


}

@pragma('vm:entry-point')
void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response) {
  print(
      "_onDidReceiveBackgroundNotificationResponse payload----chat---${response.payload}");
  var payload = jsonDecode(response.payload ?? '{}') as Map;
  if (response.notificationResponseType ==
      NotificationResponseType.selectedNotification) {}
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  print(" ${message.messageId}");

  NotificationService().showNotification(message);
}
