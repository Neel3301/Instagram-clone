import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inst_clone/resources/AuthMethod.dart';
import 'package:inst_clone/resources/StorageMethod.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDatabase({
    required String username,
    required String email,
    required String photoUrl,
    required String uid,
    required List followers,
    required List following,
    required List bookmarks,
  }) async {
    await _firestore
        .collection('users')
        .doc(AuthMethod().getCurrentUserId())
        .set(
      {
        'username': username,
        'email': email,
        'photoUrl': photoUrl,
        'uid': uid,
        'followers': [],
        'following': [],
        'bookmarks': [],
      },
    );
  }

  //upload Post
  Future<String> postDatabase(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profilePic,
  ) async {
    String res = 'something went wrong';
    try {
      String postUrl = await StorageMethod().uploadPostToStorage(file: file);

      String postId = const Uuid().v1();
      _firestore.collection('posts').doc(postId).set({
        'username': username,
        'uid': uid,
        'postId': postId,
        'datePublished': DateTime.now(),
        'postUrl': postUrl,
        'profilePic': profilePic,
        'description': description,
        'likes': [],
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // get Userdata
  Future<String> getUserData(String fieldName) async {
    DocumentSnapshot snap = await _firestore
        .collection('users')
        .doc(AuthMethod().getCurrentUserId())
        .get();
    return (snap.data() as Map<String, dynamic>)[fieldName];
  }

  // Delete Post
  Future<String> deletePost({
    required postId,
    required postUid,
  }) async {
    String res = "Some error occurred";
    String userId = AuthMethod().getCurrentUserId();
    if (postUid == userId) {
      try {
        await _firestore.collection('posts').doc(postId).delete();
        res = 'success';
      } catch (err) {
        res = err.toString();
      }
    } else {
      res = 'This is not your post, try deleting your post';
    }
    return res;
  }

  //Like Post
  Future<String> likePost({
    required String postId,
    required String uid,
    required List likes,
  }) async {
    String res = "Unable To Like Post";
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //comment
  Future<String> postComment({
    required String postId,
    required String uid,
    required String username,
    required String profilePic,
    required String text,
  }) async {
    String res = 'Unable To Comment';
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'postId': postId,
          'username': username,
          'datePublished': DateTime.now(),
          'commentId': commentId,
          'uid': uid,
          'text': text,
          'likes': [],
        });
        res = 'success';
      } else {
        res = 'Comment cant be null';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Like Comment
  Future<String> likeComment({
    required String postId,
    required String uid,
    required List likes,
    required String commentId,
  }) async {
    String res = "Unable To Like Comment";
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Comment
  Future<String> deleteComment({
    required postId,
    required postUid,
    required commentUid,
    required userId,
    required commentId,
  }) async {
    String res = "Some error occurred";
    String userId = AuthMethod().getCurrentUserId();
    if (postUid == userId || commentUid == userId) {
      try {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .delete();
        res = 'success';
      } catch (err) {
        res = err.toString();
      }
    } else {
      res =
          'Unable To delete This Comment, Try to Contact a person who owns this post or who comment on this post';
    }
    return res;
  }

  Future<String> followUser({
    required String uid,
    required String followId,
  }) async {
    String res = 'Something went wrong';
    try {
      DocumentSnapshot snapFI =
          await _firestore.collection('users').doc(followId).get();

      // DocumentSnapshot snapUI =
      //     await _firestore.collection('users').doc(followId).get();

      List followingFI = (snapFI.data()! as dynamic)['following'];
      // List followingUI = (snapUI.data()! as dynamic)['following'];

      if (followingFI.contains(uid)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
