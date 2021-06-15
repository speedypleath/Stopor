import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stopor/auth/authentication_wrapper.dart';
import 'auth/authentication_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");

  // Use this method to automatically convert the push data, in case you gonna use our data standard
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //String host = Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
  FirebaseApp firebaseApp = await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setEnabledSystemUIOverlays([]);
  //FirebaseFunctions functions = FirebaseFunctions.instance;
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
            primaryColor: Color(0xFF5BFF81),
            accentColor: Color(0xFF3AAA54),
            primarySwatch: Colors.green,
            highlightColor: Colors.green.withOpacity(0.35),
            scaffoldBackgroundColor: Color(0xFFF3F5F7),
            splashColor: Colors.transparent),
        home: AuthenticationWrapper(),
      ),
    );
  }
}
