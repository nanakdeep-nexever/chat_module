import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationHandler {
  static String? _token;

  static Future<void> init() async {
    try {
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

      if (kDebugMode) {
        print('Permission granted: ${settings.authorizationStatus}');
      }

      await _updateToken(); // Update token on initialization
    } catch (e, s) {
      print("Error during initialization: $e");
      print("Stack trace: $s");
    }
  }

  static Future<void> sendNotification(
      {required String FCM_token,
        required String title,
        required String body,
        Map? data}) async {
    final message = {
      'message': {
        'token': FCM_token,
        "data": data ?? {},
        'notification': {
          'title': title,
          'body': body,
        },
      }
    };
    Future<String> getAccessToken() async {
      const serviceAccountJson = r'''
    {
  "type": "service_account",
  "project_id": "my-chat-project-new",
  "private_key_id": "2a274a4465833805a85b09718e16e2d199a72175",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDg671tDo7ze+HH\nQYlsFdjoWtrGAXNVRteK5bhCgvhZKA2FKHrKCKy5ZqgF0kELx29rf7cmNbmMmd89\n3LOSana/bb6k8GP7E7RT8zdtL2iOO5Qlyzp3dWuWH+t23lltXaGox+U1sxJBVJBf\nRzGKAheXGTNK+v+q8ipkKQjTKEFvpi2lTdizyTIquHMC+uhMRu6AWfYupHWVjcyN\nz2u3LXvaGfW25YqRQC2k3aOtylajhfgpamdVwH7n2gofB1MeQwJMy/lDSatLMZXP\nzI8oc2s3EDWU+meURkWQabwxdf4BsPuamLE0EIvtwmt2iWXKOSa4cFuVSmRyonY2\n4SZYcn1HAgMBAAECggEATWVhW/8n+qn00cN//cTwzFfDM2J5ZO1JKz8MLjryKX/K\nUzlQM2hTw0KLa+FjR6HbedLLW6ceD789HgTtd+MRtKKXeRtNVC7+HOsy9evb3yGq\nQ20Q092AZXrbZB50CFmxUKpkeZuCmx91xItzhQleQ7zEtTb0tka5hpjGNB8EkV2o\n7z+2X7/IvuS0qtZXdgB7nVUJ/hrqqb/K3Uyq4uRENlrNiOXDecKCdisdkyxtUbb/\nG3rtTaappmfU5No+kx1Sf4HP9cl/UjYXmUWnzyt/QODfUCec1hP+LFO2vYFGiuYu\ni1pgyWi6jBIex0JrfL1sOSBxmb//xzWTjgFJZLgJOQKBgQDxGmFljzM8xmZTynBA\n7oec3H3f1nkPjAoCh0s4yobUJIb6TzqFJZIWjyu6+V9jSWR46tdq5MZ0qvOrfEzZ\nKL6k7Gru9/52v3RKJW9S3Wn6XYsZmihcxI9RnGTznBImpkd31qDQThWb5n2HSt6k\npm/1RXhQb1vUvhT0LkBxqq8M/wKBgQDu0WZK+ZsoYdLuGeW4XJK0fOjza0Izh/lr\nvIT1FyxPWeiB+muw4i/w2wW3b0eW/3jJ58uDyyZsDjdA5FFJK67tUbWCYME7/A4Z\njIGPcm4HqlW1LAOqrTIfa9gFy64GUUXAY610XcOh1XYRqJjQ2U7MbFlTasvhnJ6B\nFzAwHMjnuQKBgHDIl2ELwLsgUAPIQgSN0FBXcGaCDHVyW8hdA5oYW0PnpmB3KXfZ\nYGI/LQS03KM0VNSffo+ZXyB6S6wfZE99WNkLYuZQie+AleSNaGsJ+iZNFeGvFEx5\nAlX549t1WaRMykfL1cQ7kq4v/u6H3miFFwBUM/jkbr+w/1pOPIUvg91/AoGAAnh8\nHG50onhQnFH8RGoAwolAR7RmXO4dMHYk0fxJYxDFDQMwNgZBBLbfWkR2cyN1dnFF\nc7mYTinffHZgOOeQybe8rvqdRSeYZb9EX92JMd8bP+KSryNXj2eoNnci98HDfPgL\nBVcq/POeYxRhcFevLwI38lr6fP0HzsIUp4rEsVECgYAdkxNHdTANPefRDWobJYLi\nazcplQHrQgEKjmpc/l5GegjNTIFcyygqNsBtZOTYquTsn5dZpf6NV+rKh9pefYPM\nq9r44dHBVC2IOjd1foo4rEUOzU28hyslJZE0oJBHukpas4AwSvG3iV2aOAXtkgPl\nEaZ5pmXJ9PclZMmuvbZfhw==\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-ubpp5@my-chat-project-new.iam.gserviceaccount.com",
  "client_id": "117333176702881285772",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-ubpp5%40my-chat-project-new.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

 ''';

      final accountCredentials =
      ServiceAccountCredentials.fromJson(serviceAccountJson);

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final authClient =
      await clientViaServiceAccount(accountCredentials, scopes);

      return (authClient.credentials.accessToken.data).toString();
    }

    final accessToken = await getAccessToken();

    try {
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/project-tracker-nk/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<void> _updateToken() async {
    try {
      print("Fetching token...");
      final messaging = FirebaseMessaging.instance;
      _token = await messaging.getToken();
      if (_token != null) {
        if (kDebugMode) {
          print('Registration Token: $_token');
        }
      } else {
        print("Failed to get token");
      }
    } catch (e, s) {
      print("Error retrieving token: $e");
      print("Stack trace: $s");
    }
  }

  static String? get token => _token;
}