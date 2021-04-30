import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stopor/auth/authentication_wrapper.dart';
import 'package:stopor/auth/login_screen.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/widgets/event_card.dart';

import 'auth/authentication_service.dart';
import 'data.dart';
import 'screens/news_feed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String host = Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
  await Firebase.initializeApp();
  FirebaseFunctions functions = FirebaseFunctions.instance;
  // FirebaseFirestore.instance.settings =
  //   Settings(host: host, sslEnabled: false, persistenceEnabled: false);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (context) => AuthenticationService(FirebaseAuth.instance),
        ),
        Provider<DatabaseService>(
          create: (context) => DatabaseService(FirebaseFirestore.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Stopor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.green,
            highlightColor: Colors.green.withOpacity(0.2),
            scaffoldBackgroundColor: Color(0xFFF3F5F7),
            splashColor: Colors.transparent),
        home: AuthenticationWrapper(),
      ),
    );
  }
}
