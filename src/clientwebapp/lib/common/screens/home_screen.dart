import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clientwebapp/res/custom_colors.dart';
import 'package:clientwebapp/authentication/google_sign_in/utils/authentication.dart';
import 'package:clientwebapp/common/widgets/app_bar_title.dart';
import 'package:flutter/foundation.dart';
import 'package:clientwebapp/authentication/google_sign_in/screens/sign_in_screen.dart';
import 'package:clientwebapp/common/screens/list_screen.dart';
import 'package:clientwebapp/common/screens/speech_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late User _user;
  bool _isSigningOut = false;
  int _selectedIndex = 0;
  final newListTextController = TextEditingController();
  bool _isShow = false;
  bool _listNameEntered = false;
  bool _newListCreatedShow = false;

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

  Route _routeToSpeechScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          SpeechScreen(user: _user),
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

  void _updateNewListEntry() {
    print('change detected');
    setState(() {
      _listNameEntered = true;
    });
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
        Navigator.of(context).pushReplacement(_routeToSpeechScreen());
        break;
      case 3:
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
            icon: Icon(Icons.mic),
            label: 'Speech',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
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
                        setState(() {
                          //displayText = newListTextController.text;
                          _newListCreatedShow = false;
                          _isShow = true;
                          newListTextController.text = '';
                        });
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
              const SizedBox(
                height: 10,
              ),
              const SizedBox(height: 16.0),
              Visibility(
                  visible: _isShow,
                  child: ElevatedButton(
                      onPressed: () {
                        createNewList(newListTextController.text, _user.uid);
                      },
                      child: const Text('Save List'))),
              const SizedBox(height: 8.0),
              Visibility(
                  visible: _isShow,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          //displayText = newListTextController.text;
                          _isShow = false;
                        });
                      },
                      child: const Text('Cancel'))),
              const SizedBox(height: 8.0),
              Text(
                _user.displayName!,
                style: const TextStyle(
                  color: Palette.firebaseYellow,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _user.uid,
                style: const TextStyle(
                  color: Palette.firebaseYellow,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '( ${_user.email!} )',
                style: const TextStyle(
                  color: Palette.firebaseOrange,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<http.Response> createNewList(String listName, String userId) async {
    String url = dotenv.env['FRONTEND_URL'].toString();

    Uri uri;

    if (kReleaseMode) {
      print('mode${dotenv.env['FRONTEND_URL']}');
      uri = Uri.https(url, '/newlist');
    } else {
      print('mode${dotenv.env['FRONTEND_URL']}');
      uri = Uri.http(url, '/newlist');
    }

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {'listName': listName, 'userId': userId},
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.
      print('response code to new list: ${response.statusCode}');

      setState(() {
        //displayText = newListTextController.text;
        _isShow = false;
        _newListCreatedShow = true;
      });
      return response;
    } else {
      // If the server did not return a 200 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create list.');
    }
  }
}
