import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signUp(String email, String password) async {
    final user = (await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    return user.uid;
  }

  Future<String> signIn(String email, String password) async {
    final FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    return user.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> addUser(String uid, String userName, String email) async {
    final newUserData = {
      'uid': uid,
      'userName': userName,
      'email': email,
    };
    Firestore.instance.collection('users').document(uid).setData(newUserData);
  }
}
