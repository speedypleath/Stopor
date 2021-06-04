import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stopor/auth/login.dart';
import 'package:stopor/screens/bottom_nav.dart';

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) return BottomNav();
    return LoginScreen();
  }
}
