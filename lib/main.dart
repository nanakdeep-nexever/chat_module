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

import 'Bloc/message_send.dart';
import 'Notification_handel/notification_services.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => MessagingBloc());
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupLocator();
  runApp(const MyApp());
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
      print('Received message on screen: $message');
      _messagingBloc.addstream(message);
    });
    // setupBackgroundMessageHandler();
    super.initState();

    final notificationService = NotificationService();
    notificationService.initialize();
    notificationService.initMessaging();
  }

  void setupBackgroundMessageHandler() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _messagingBloc.addstream(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _messagingBloc.addstream(message);
      MessagingBloc().handleMessage(
        message,
      );
    });
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
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter',
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        home: user == null ? const Login_Screen() : const ChatHome(),
      ),
    );
  }
}
