import 'dart:io';

import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/profile_bloc/profile_bloc.dart';
import 'package:chat_module/Screens/chatroom/chatList.dart';
import 'package:chat_module/Screens/loginScreen.dart';
import 'package:chat_module/Theme_data/chat_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'Bloc/message_send.dart';
import 'Notification_handel/Notification_handle.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final locator = GetIt.instance;
NotificationHandler notificatioHendler = NotificationHandler();

void setupLocator() {
  locator.registerLazySingleton(() => MessagingBloc());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_test');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null, // iOS settings can be added here
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  setupLocator();

  await NotificationHandler.init();
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

  runApp(const MyApp());
}

void _handleForegroundMessage(RemoteMessage message) {
  if (message.notification != null) {
    _showNotification(message);
  }
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  if (url.isNotEmpty == true) {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
  return "";
}

Future<void> _showNotification(RemoteMessage message) async {
  final String? imgUrl = message.data['imageUrl'] ??
      'https://www.pushengage.com/wp-content/uploads/2023/06/In-App-Notification-Examples.png';
  String? imagePath;

  if (imgUrl != null && imgUrl.isNotEmpty) {
    imagePath = await _downloadAndSaveFile(imgUrl, 'notification_image.jpg');
  }
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    largeIcon: imagePath != null ? FilePathAndroidBitmap(imagePath) : null,
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: null, // iOS settings can be added here
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title.toString(),
    message.notification?.body.toString(),
    platformChannelSpecifics,
    payload: 'item x',
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MessagingBloc _messagingBloc;

  @override
  void initState() {
    _messagingBloc = locator<MessagingBloc>();
    _messagingBloc.messageStream.listen((message) {
      print('object on Screen $message');
      _messagingBloc.addstream(message);
    });
    setupbackground();
    super.initState();
  }

  void _handleMessage(RemoteMessage message) {
    _messagingBloc.addstream(message);
  }

  void setupbackground() async {
    print("trigrred");
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("not empty");
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  @override
  void dispose() {
    _messagingBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Poppins");
    User? user = FirebaseAuth.instance.currentUser;

    Chat_Module_Theme theme = Chat_Module_Theme(textTheme);
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter',
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        home: user == null ? const Login_Screen() : const ChatHome(),
      ),
    );
  }
}
