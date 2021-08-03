import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:paricon/services/playerDatabase.dart';

class Auth {
  final FirebaseApp app;
  late FirebaseAuth _auth;

  Auth(this.app) {
    _auth = FirebaseAuth.instanceFor(app: app);
  }

  Stream<bool> get userCheck => _auth.authStateChanges().map(
        (event) => event != null,
      );

  /*Stream<bool> get userCheck {
    late BehaviorSubject<bool> behaviorSubject;
    behaviorSubject = BehaviorSubject(
      onListen: () => _auth.authStateChanges().listen(
        (event) {
          if (event == null) behaviorSubject.add(false);
          final user = event;
          /*print("User Available");
          print(user);
          //UserInfo userInfo = user!.providerData[0];
          print(DateTime.now());*/
          //user!.providerData.add(UserInfo());
          behaviorSubject.add(true);
        },
      ),
    );
    return behaviorSubject.stream;
  }*/

  User? get currentUser => _auth.currentUser;

  Future signInAnonymous({String name = ""}) async {
    try {
      await _auth.signInAnonymously();
      await _auth.currentUser!.updateDisplayName(name);
      await PlayerDatabase(app).createPlayer(_auth.currentUser!);

      //return _auth.currentUser;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future get signOut async {
    final User deleteUser = _auth.currentUser!;
    final bool isUnknownUser = deleteUser.isAnonymous;
    if (isUnknownUser) {
      await PlayerDatabase(app, uid: deleteUser.uid).deleteUser;
      await deleteUser.delete();
    }
    _auth.signOut();
  }

  Future get signInWithGoogle async {
    final credential = await googleCredentials;
    if (credential == null) return;
    await _auth.signInWithCredential(credential);

    await PlayerDatabase(app).createPlayer(_auth.currentUser!);
  }

  Future<AuthCredential?> get googleCredentials async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    try {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return credential;
    } on PlatformException catch (e) {
      //print(e);
      return null;
    }
  }

  Future<void> updateName(String newName) async {
    await _auth.currentUser!.updateDisplayName(newName);
    await PlayerDatabase(app, uid: _auth.currentUser?.uid).updateName(newName);
  }

  Future<dynamic> get reSignIn async {
    try {
      final cred = await googleCredentials;

      await _auth.currentUser!.linkWithCredential(cred!);
      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      return e;
    }
  }
}
