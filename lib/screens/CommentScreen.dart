import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inst_clone/resources/FirestoreMethod.dart';
import 'package:inst_clone/utils/SnackBarUtil.dart';
import 'package:inst_clone/widgets/CommentCardWidget.dart';

class CommentScreen extends StatefulWidget {
  final postId;
  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController _commentController = TextEditingController();

  bool getAllData = false;

  String? usernameData;
  String? profilePicUrlData;
  String? uidData;
  String? postIdData;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    String username = await FirestoreMethod().getUserData('username');
    String profilePicUrl = await FirestoreMethod().getUserData('photoUrl');
    String uid = await FirestoreMethod().getUserData('uid');
    setState(() {
      usernameData = username;
      profilePicUrlData = profilePicUrl;
      uidData = uid;
      getAllData = true;
    });
  }

  void commentThis() async {
    String res = await FirestoreMethod().postComment(
      postId: widget.postId,
      uid: uidData!,
      username: usernameData!,
      profilePic: profilePicUrlData!,
      text: _commentController.text,
    );
    _commentController.text = '';

    if (res != 'success') {
      showSnackBar(res, context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getAllData == false
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  )),
              title: const Text(
                'Comments',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              centerTitle: false,
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('datePublished', descending: true)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) => CommentCardWidget(
                    snap: snapshot.data!.docs[index],
                  ),
                );
              },
            ),
            bottomNavigationBar: Container(
              height: kToolbarHeight,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(profilePicUrlData!),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Comment as ${usernameData!}',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: commentThis,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: const Text(
                        'Post',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
