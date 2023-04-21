import 'package:flutter/material.dart';
//import 'package:clientwebapp/common/screens/home_screen.dart';
import 'package:clientwebapp/authentication/google_sign_in/screens/sign_in_screen.dart';

void main() async {
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
