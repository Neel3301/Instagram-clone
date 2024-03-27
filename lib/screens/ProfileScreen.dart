import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inst_clone/resources/AuthMethod.dart';
import 'package:inst_clone/resources/FirestoreMethod.dart';
import 'package:inst_clone/screens/LoginScreen.dart';
import 'package:inst_clone/utils/SnackBarUtil.dart';

import '../widgets/FollowBtnWidget.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isDataLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isDataLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          // .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        userData = userSnap.data()!;
        postLen = postSnap.docs.length;
        followers = userSnap.data()!['followers'].length;
        following = userSnap.data()!['following'].length;
        isFollowing = userSnap
                .data()!['following']
                .contains(FirebaseAuth.instance.currentUser!.uid)
            ? true
            : false;
      });
    } catch (err) {
      showSnackBar(err.toString(), context);
    }

    setState(() {
      isDataLoading = false;
    });
  }

  followThis() async {
    String res = await FirestoreMethod().followUser(
      uid: FirebaseAuth.instance.currentUser!.uid,
      followId: userData['uid'],
    );
    setState(() {
      isFollowing = true;
      followers++;
    });
    if (res != 'success') {
      showSnackBar(res, context);
    }
  }

  unFollowThis() async {
    String res = await FirestoreMethod().followUser(
      uid: FirebaseAuth.instance.currentUser!.uid,
      followId: userData['uid'],
    );
    setState(() {
      isFollowing = false;
      followers--;
    });
    if (res != 'success') {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isDataLoading
        ? Scaffold(
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            )),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
              title: Text(
                userData['username'],
                style: TextStyle(color: Colors.black),
              ),
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 48,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildStatColumn(postLen, 'Post'),
                                buildStatColumn(followers, 'Followers'),
                                buildStatColumn(following, 'Following'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      FirebaseAuth.instance.currentUser!.uid == widget.uid
                          ? FollowBtnWidget(
                              function: () async {
                                await AuthMethod().signOut();
                                Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const LoginScreen();
                                }), (route) => false);
                              },
                              bgColor: Colors.white,
                              borderColor: Colors.black,
                              text: 'Sign Out',
                              textColor: Colors.black,
                            )
                          : isFollowing
                              ? FollowBtnWidget(
                                  function: unFollowThis,
                                  bgColor: Colors.white,
                                  borderColor: Colors.black,
                                  text: 'Unfollow',
                                  textColor: Colors.black,
                                )
                              : FollowBtnWidget(
                                  function: followThis,
                                  bgColor: Colors.blue,
                                  borderColor: Colors.blue,
                                  text: 'Follow',
                                  textColor: Colors.white,
                                ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 1.5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          DocumentSnapshot snap =
                              (snapshot.data! as dynamic).docs[index];
                          return Container(
                            child: Image.network(
                              snap['postUrl'],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.blue),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
      ],
    );
  }
}
