import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Screens/loginScreen.dart';
import 'package:chat_module/Theme_data/chat_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Poppins");

    Chat_Module_Theme theme = Chat_Module_Theme(textTheme);
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter',
        theme: brightness == Brightness.light ? theme.light() : theme.dark(),
        home: Login_Screen(),
      ),
    );
  }
}
