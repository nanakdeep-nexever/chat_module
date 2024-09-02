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
  "project_id": "project-tracker-nk",
  "private_key_id": "b3150727ca85e278a83dfb2d9854078cde4aaf92",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDSwfkbDCeBygj1\nYYJsMVjzVwoALWSCilbCUaqAdnVieX0l5GhEosxB6RNY357OCAixlb4TFgtZdHpS\nMyUb6lf4pHAkt1GDn4xcZIEzp/N7AEFJ4NimgpGuOHE+IExp7RqkG0grUHKfDXXr\n7vYyL5t32q0pEAZNFKKF4yAnDGmT/hMDLNqM7nw20PLCrUQbYOpWHQ3px9jOvvHz\nnbBW+7UO5kF4PkWMLmsB9QHRarwhUVXgYR3WiUzGp9lP4IhQp4Seqe+TIbGJ5lEj\n+SbvjvhU0SZCQqiX9Zf9gwmz+UcYKMjfowDuAIm4StV/dcjhyO86uyOBqnpPkZsr\n2T5WGXRrAgMBAAECggEAFJArcdM9dlrguK+JlGyhXQ2Er5OLB0Rf7N65KYaLs0Hf\nDySAp3qECyxABuXuoY1dt8hZ8fr7iYAlWfU2hvyi4uLvmo17IEIGMl+PmzTx7lh0\nhk5Jvr+yxUWP7i7wwoCi638XJNUl3qHnSJx/z4UfAJ8vHpIH/PS19L7X1lq0lGVC\nXcztEMpnDKqw/phwvW4mZIXtrKIxt0XhdkPrLXo5avFGTcK8aG+zlv+OzX09sLYH\nVPlbapkTbRrbmwoZITOy9l16D4rGP8VRsv1pDYZ/NNgYDnTN8LWyoRmJUsQQf7Hc\nyfJhDKEwfEkn8M2f3+SDRyy6w00ZM7C5HJFPt6SPHQKBgQD/ykP/Y1/gLsXto24Z\nJ9RK/gJChH6jFHmtjpXlV/1cm+a0N4IepFf4V5JbnOTUA3i1eyePveXvLFNzlvQY\nFiw01TjCk7/HvdLfe49U7MTcr0BdaBHh8+08wqLflM1XM2J7xRahi8khJmjJ6YWJ\nxrpmUOCm+XsZ1ll9/aq8fCjeJwKBgQDS7j9VoHG439Rge+RRREP+KmpF/YfkR8fe\nvgXA4A3MqXurIEXAdJpJCFGwqiNZBed0O2JNwbmcy8AVuB5kYcN2Gz/XwcUrhqGh\nvox3KybE7Yic/847eOSH6O2TV+gaIgXQfQRugj9WxFmrtb6C12GJtOn8m9src2OV\nqgDGbR2mHQKBgG1il/WND6EVH3tiWmDTkYuIWHsNogInbWl1AlETcbu6x8vluPVV\nnnELMgGPdKPd4C7rvZ1QvhWrxPw3X6c1RC5LyHwdJvRKDvWXJ1JP9lfRchr/uDYC\nVD+ZlIE8ZxuVU9ZOEEGBP7+3ZzSBcqPaojfC+m8tXSFNcvPYGL2F8wwdAoGAOjTe\nq11kJHU34QwvPDHPZYME4p2M83TPdesQIWJyzGh0pQt51BsZPFAcYtkAeh+D+HIu\ntXBhLSCYuCWf1WmZC62HV520MEetsLmpf3Ub9Lnrug9pNMYuokan0MIwXY3H9vmY\n0HoGyoXSjOzRTr/qvZp7+2Zy+7GS6IkKP7d6uA0CgYBwP/qXC87zi4OKNJqhNGfy\n+JMCWdeXqF9TY7EG8KfeS2EvP/cX/leqqDwzi8g2oVn+DoWlZ6hhHdyLbu5KAQtI\nVuEDvN6kq3qgEK4QBCXfNCkaJTB2pDcg9LYHnbVFN88ncjLc2I5ohmEjn3U0RUvc\nF8QlJyPaQDYwz2rJhL4O/w==\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-5mxpz@project-tracker-nk.iam.gserviceaccount.com",
  "client_id": "118314086459840580181",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-5mxpz%40project-tracker-nk.iam.gserviceaccount.com",
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