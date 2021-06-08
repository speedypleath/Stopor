import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stopor/auth/authentication_wrapper.dart';
import 'auth/authentication_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //String host = Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080';
  await Firebase.initializeApp();
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
