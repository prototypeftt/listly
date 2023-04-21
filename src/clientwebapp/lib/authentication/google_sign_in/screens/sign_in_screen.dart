import 'package:flutter/material.dart';
import 'package:clientwebapp/res/custom_colors.dart';
import 'package:clientwebapp/authentication/google_sign_in/utils/authentication.dart';
import 'package:clientwebapp/authentication/google_sign_in/widgets/google_sign_in_button.dart';
//import 'package:clientwebapp/common/widgets/custom_back_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.firebaseNavy,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Image.asset(
                            'assets/firebase_logo.png',
                            height: 160,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Listly',
                          style: TextStyle(
                            color: Palette.firebaseYellow,
                            fontSize: 40,
                          ),
                        ),
                        const Text(
                          'Authentication',
                          style: TextStyle(
                            color: Palette.firebaseOrange,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                    future: Authentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error initializing Firebase');
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return const GoogleSignInButton();
                      }
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Palette.firebaseOrange,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            //const CustomBackButton(),
          ],
        ),
      ),
    );
  }
}
