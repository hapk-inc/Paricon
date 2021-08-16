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

  User? get currentUser => _auth.currentUser;

  Future signInAnonymous({String name = ""}) async =>
      await _auth.signInAnonymously().then(
            (value) async => await _auth.currentUser!.updateDisplayName(name),
          );

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
      throw e;
    }
  }

  Future<void> updateName(String newName) async {
    await _auth.currentUser!.updateDisplayName(newName);
    await PlayerDatabase(app, uid: _auth.currentUser?.uid).updateName(newName);
  }

  Future get reSignIn async {
    final cred = await googleCredentials;

    await _auth.currentUser!.linkWithCredential(cred!);
  }
}
