import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:paricon/services/playerDatabase.dart';

class Auth {
  final FirebaseApp app;
  late FirebaseAuth _auth;

  Auth(this.app) {
    _auth = FirebaseAuth.instanceFor(app: app);
  }

  Stream<bool> get userCheck =>
      _auth.authStateChanges().map((event) => event != null);

  User? get currentUser => _auth.currentUser;

  Future signInAnonymous({String name = ""}) async {
    try {
      await _auth.signInAnonymously();
      await _auth.currentUser!.updateProfile(displayName: name);
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
    try {
      final GoogleSignInAccount googleUser =
          await (GoogleSignIn().signIn() as FutureOr<GoogleSignInAccount>);

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ) as GoogleAuthCredential;
      await _auth.signInWithCredential(credential);
      print("Google SIgn in over");
      print(_auth.currentUser);
      await PlayerDatabase(app).createPlayer(_auth.currentUser!);
    } catch (e) {
      print(e);
    }
  }
}
