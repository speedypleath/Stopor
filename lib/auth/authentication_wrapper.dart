import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stopor/auth/login_screen.dart';
import 'package:stopor/screens/bottom_nav.dart';
import 'package:stopor/screens/news_feed.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) return BottomNav();
    return LoginPage();
  }
}
