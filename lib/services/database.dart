import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class MyDatabase {
  late FirebaseDatabase _firebaseDatabase;
  MyDatabase(FirebaseApp _app) {
    _firebaseDatabase = FirebaseDatabase(app: _app);
  }

  DatabaseReference get playerRef =>
      _firebaseDatabase.reference().child("players");
  DatabaseReference get roomRef => _firebaseDatabase.reference().child("rooms");
  DatabaseReference get boardRef =>
      _firebaseDatabase.reference().child("boards");
}