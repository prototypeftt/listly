import 'package:clientwebapp/common/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clientwebapp/res/custom_colors.dart';
import 'package:clientwebapp/authentication/google_sign_in/utils/authentication.dart';
import 'package:clientwebapp/common/widgets/app_bar_title.dart';
import 'package:clientwebapp/authentication/google_sign_in/screens/sign_in_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  ListScreenState createState() => ListScreenState();
}

class Lists {
  final String listid;
  final String listname;

  Lists(this.listid, this.listname);

  Lists.fromJson(Map<String, dynamic> json)
      : listid = json['listid'],
        listname = json['listname'];
}

class ListScreenState extends State<ListScreen> {
  late User _user;
  int _selectedIndex = 0;
  final newListTextController = TextEditingController(text: "List Name...");
  List listOfItems = List.generate(20, (index) => 'Sample List - $index');
  //late List listOfItems;
  List<Lists> listOfLists = [];

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

  Route _routeToHomeScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
        user: _user,
      ),
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
    _user = widget._user;
    getLists(_user.uid);
    super.initState();
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(_routeToHomeScreen());
        break;
      case 1:
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder<List<Lists>>(
      future: getLists(_user.uid),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Text('loading...');
          default:
            if (snapshot.hasError) {
              print("snapshot data ${snapshot.data}");
              print("snapshot error ${snapshot.error}");
              return Text('Error 1: ${snapshot.error}');
            } else {
              return createListView(context, snapshot);
            }
        }
      },
    );

    return Scaffold(
      backgroundColor: Palette.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Palette.firebaseNavy,
        title: const AppBarTitle(
          sectionName: 'Lists',
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: futureBuilder,
      /*ListView.separated(
        itemCount: listOfItems.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              print('Clicked on item #$index'); // Print to console
              _getLists(_user.uid);
            },
            title: Text(listOfItems[index] as String),
            subtitle: Text('Sample subtitle for item #$index'),
            leading: Container(
              height: 50,
              width: 50,
              color: Colors.amber,
            ),
            trailing: Icon(Icons.edit),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),*/
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Lists> values = snapshot.data;
    return ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            ListTile(
              title: Text(values[index].listname),
            ),
            const Divider(
              height: 2.0,
            ),
          ],
        );
      },
    );
  }

  List<Lists> parseLists(String responseBody) {
    List mapData = jsonDecode(responseBody)['list'];

    List<Lists> lists = mapData.map((list) => Lists.fromJson(list)).toList();
    return lists;
  }

  Future<List<Lists>> getLists(String userId) async {
    String url = "localhost:5000";

    final params = {
      'userId': userId,
    };

    final uri = Uri.http(url, '/getlists', params);
    //print('URI getlists : $uri'); // Print to console

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<Lists> lists = parseLists(response.body);
      print("@@@@@ lists: " + lists.length.toString());
      return lists;
    } else {
      throw Exception('Failed to get list.');
    }
  }
}
