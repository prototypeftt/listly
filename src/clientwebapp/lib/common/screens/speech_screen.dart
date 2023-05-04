import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clientwebapp/res/custom_colors.dart';
import 'package:clientwebapp/authentication/google_sign_in/utils/authentication.dart';
import 'package:clientwebapp/common/widgets/app_bar_title.dart';
import 'package:flutter/foundation.dart';
import 'package:clientwebapp/authentication/google_sign_in/screens/sign_in_screen.dart';
import 'package:clientwebapp/common/screens/list_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  late User _user;
  bool _isSigningOut = false;
  int _selectedIndex = 0;
  
  bool _isShow = false;


  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _routeToListScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ListScreen(user: _user),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _user = widget._user;
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        // only scroll to top when current index is selected.
        break;
      case 1:
        Navigator.of(context).pushReplacement(_routeToListScreen());
        break;
      case 2:
        print('signing out');
        setState(() {
          _isSigningOut = true;
        });
        await Authentication.signOut(context: context);
        setState(() {
          _isSigningOut = false;
        });
        if (!mounted) return;
        Navigator.of(context).pushReplacement(_routeToSignInScreen());
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Palette.firebaseNavy,
        title: const AppBarTitle(
          sectionName: 'Home',
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        mouseCursor: SystemMouseCursors.grab,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Sign Out',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(),
              Visibility(
                visible: _newListCreatedShow,
                child: const Text(
                  'New List Created',
                  style: TextStyle(
                    color: Palette.firebaseYellow,
                    fontSize: 26,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Visibility(
                  visible: !_isShow,
                  child: ElevatedButton(
                      onPressed: () {

                      },
                      child: const Text('Create New List...'))),
              Visibility(
                  visible: _isShow,
                  child: TextField(
                    controller: newListTextController,
                    obscureText: false,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'List name',
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}