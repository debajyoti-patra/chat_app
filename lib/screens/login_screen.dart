import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/ScreenButton.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  void login() async {
    try {
      if (email == '' || password == '') {
        showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
                message: 'Please provide both email and password'));
        return;
      }
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      if (userCredential.user != null) {
        showTopSnackBar(Overlay.of(context),
            CustomSnackBar.success(message: 'LogIn Successful'));
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, ChatScreen.id);
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: e.message.toString(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = value;
              },
              decoration:
                  kInputDecoration.copyWith(hintText: 'Enter your email'),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (value) {
                password = value;
              },
              decoration:
                  kInputDecoration.copyWith(hintText: 'Enter your password'),
            ),
            SizedBox(
              height: 24.0,
            ),
            PaddingButton(
              title: 'Log In',
              colour: Colors.lightBlueAccent,
              onPressed: () {
                login();
              },
            )
          ],
        ),
      ),
    );
  }
}
