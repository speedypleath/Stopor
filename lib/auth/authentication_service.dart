import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:stopor/database/database_service.dart';
import 'package:http/http.dart' as http;

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  User getUser() => _firebaseAuth.currentUser;

  Future<String> facebookSignIn({String email, String password}) async {
    try {
      final FacebookLogin facebookSignIn = new FacebookLogin();
      final FacebookLoginResult result =
          await facebookSignIn.logIn(['email', 'public_profile']);
      final facebookAuthCred =
          FacebookAuthProvider.credential(result.accessToken.token);
      await _firebaseAuth.signInWithCredential(facebookAuthCred);
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseAuth.currentUser.uid);
      var importFacebookEvents =
          FirebaseFunctions.instance.httpsCallable('syncFacebookEventsInstant');
      final graphResponse = await http.get(Uri.parse(
          "https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${result.accessToken.token}"));

      final profile = jsonDecode(graphResponse.body);
      print(profile);
      importFacebookEvents({"facebookToken": result.accessToken.token})
          .whenComplete(() => print("gata"));
      userRef.get().then((user) {
        if (!user.exists) {
          userRef.set({
            "authToken": result.accessToken.token,
            "name": profile["name"],
            "email": profile["email"]
          });
        } else {
          userRef.update({"authToken": result.accessToken.token});
        }
      });

      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((newUser) => {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(newUser.user.uid)
                    .set({}),
                newUser.user.sendEmailVerification()
              });
      return "Signed up";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
