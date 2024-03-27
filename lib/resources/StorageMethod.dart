import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:inst_clone/resources/AuthMethod.dart';
import 'package:uuid/uuid.dart';

class StorageMethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // TODO Uploading Profile Pic
  Future<String> uploadProfilePicToStorage({
    required Uint8List file,
  }) async {
    String userId = AuthMethod().getCurrentUserId();
    Reference ref = _storage.ref().child('profilePic').child(userId);

    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadProfilePicUrl = await snap.ref.getDownloadURL();

    return downloadProfilePicUrl;
  }

  // TODO Uploading Post Picture
  Future<String> uploadPostToStorage({
    required Uint8List file,
  }) async {
    String userId = AuthMethod().getCurrentUserId();
    Reference ref =
        _storage.ref().child('posts').child(userId).child(const Uuid().v1());

    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadPostUrl = await snap.ref.getDownloadURL();

    return downloadPostUrl;
  }
}
