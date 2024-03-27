import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:inst_clone/resources/FirestoreMethod.dart';
import 'package:inst_clone/resources/StorageMethod.dart';

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //TODO Create User
  Future<String> createUser({
    required Uint8List? file,
    required String username,
    required String email,
    required String password,
  }) async {
    String res = 'Unable To Create Account';
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          file != null) {
        //TODO Registering User
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // TODO Storing ProfilePic
        String photoUrl =
            await StorageMethod().uploadProfilePicToStorage(file: file!);

        await FirestoreMethod().createUserDatabase(
          username: username,
          email: email,
          photoUrl: photoUrl,
          uid: getCurrentUserId(),
          followers: [],
          following: [],
          bookmarks: [],
        );

        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> logedInUser({
    required String email,
    required String password,
  }) async {
    String res = 'Unable to Loged In';
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'success';
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  //TODO Gives Current User ID
  String getCurrentUserId() {
    return _auth.currentUser!.uid;
  }

  //signOut
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
