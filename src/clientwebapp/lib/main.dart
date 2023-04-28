import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clientwebapp/authentication/google_sign_in/screens/sign_in_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  if (kReleaseMode) {
    await dotenv.load(fileName: ".env.production");
    print('production mode');
  } else {
    await dotenv.load(fileName: ".env.development");
    print('development mode');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'OpenSans',
      ),
      home: const SignInScreen(),
      //home: const HomeScreen(),
    );
  }
}
