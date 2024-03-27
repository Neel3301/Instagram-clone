import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inst_clone/screens/DevInfo.dart';
import 'package:inst_clone/screens/FeedScreen.dart';
import 'package:inst_clone/screens/ProfileScreen.dart';
import 'package:inst_clone/screens/SearchScreen.dart';
import 'package:inst_clone/screens/UploadScreen.dart';

List<Widget> screensUtils = [
  const FeedScreen(),
  const SearchScreen(),
  const UploadScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
  const DevInfo(),
];
