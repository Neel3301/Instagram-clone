import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inst_clone/resources/AuthMethod.dart';
import 'package:inst_clone/resources/FirestoreMethod.dart';
import 'package:inst_clone/screens/CommentScreen.dart';
import 'package:inst_clone/utils/SnackBarUtil.dart';
import 'package:intl/intl.dart';

class PostCardWidget extends StatefulWidget {
  final snap;
  const PostCardWidget({
    super.key,
    required this.snap,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  bool getAllData = true;
  List userBookmarks = [];
  bool isBookmark = false;
  @override
  void initState() {
    super.initState();
    getComments();
    printallvaluesfromarray();
  }

  Future<void> printallvaluesfromarray() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthMethod().getCurrentUserId())
        .get();

    if (docSnapshot.exists) {
      dynamic data = docSnapshot.data();
      if (data != null && data['bookmarks'] is List) {
        userBookmarks = data['bookmarks'] as List<dynamic>;
      }
    }
  }

  int commentLen = 0;
  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
    setState(() {});
  }

  commentThis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentScreen(
          postId: widget.snap['postId'],
        ),
      ),
    );
  }

  delPost() async {
    String res = await FirestoreMethod().deletePost(
      postId: widget.snap['postId'],
      postUid: widget.snap['uid'],
    );
    if (res == 'success') {
      showSnackBar('Post Deleted', context);
    } else {
      showSnackBar(res, context);
    }
  }

  likeThisPost() async {
    String res = await FirestoreMethod().likePost(
      postId: widget.snap['postId'],
      uid: AuthMethod().getCurrentUserId(),
      likes: widget.snap['likes'],
    );

    if (res != 'success') {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return getAllData == false
        ? Container(
            margin: const EdgeInsets.all(12),
            height: MediaQuery.of(context).size.height * 0.7,
            width: double.infinity,
            color: Colors.grey.shade300,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(widget.snap['profilePic']),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            widget.snap['username'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    children: [
                                      SimpleDialogOption(
                                        padding: const EdgeInsets.all(14),
                                        child: const Text('Delete Post'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          delPost();
                                        },
                                      ),
                                      SimpleDialogOption(
                                        padding: const EdgeInsets.all(14),
                                        child: const Text('Repot Post'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          showSnackBar(
                                            'Post Reported',
                                            context,
                                          );
                                        },
                                      ),
                                      SimpleDialogOption(
                                        padding: const EdgeInsets.all(14),
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(Icons.more_vert))
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     image:
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        );
                      }
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: likeThisPost,
                          icon: widget.snap['likes'].contains(
                            AuthMethod().getCurrentUserId(),
                          )
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_outline,
                                ),
                        ),
                        Text(
                          '${widget.snap['likes'].length} likes',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: commentThis,
                          icon: Icon(
                            Icons.comment_outlined,
                          ),
                        ),
                        InkWell(
                          onTap: commentThis,
                          child: Text('${commentLen} Comments'),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Container(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "  ${widget.snap['description']}",
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
