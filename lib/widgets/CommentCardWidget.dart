import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inst_clone/resources/AuthMethod.dart';
import 'package:inst_clone/resources/FirestoreMethod.dart';
import 'package:inst_clone/utils/SnackBarUtil.dart';
import 'package:intl/intl.dart';

class CommentCardWidget extends StatefulWidget {
  final snap;
  const CommentCardWidget({super.key, required this.snap});

  @override
  State<CommentCardWidget> createState() => _CommentCardWidgetState();
}

class _CommentCardWidgetState extends State<CommentCardWidget> {
  @override
  Widget build(BuildContext context) {
    void likeThisComment() async {
      String res = await FirestoreMethod().likeComment(
        postId: widget.snap['postId'],
        uid: AuthMethod().getCurrentUserId(),
        likes: widget.snap['likes'],
        commentId: widget.snap['commentId'],
      );
      if (res != 'success') {
        showSnackBar(res, context);
      }
    }

    void deleteThis() async {
      String res = await FirestoreMethod().deleteComment(
        postId: widget.snap['postId'],
        postUid: widget.snap['uid'],
        commentUid: widget.snap['uid'],
        userId: AuthMethod().getCurrentUserId(),
        commentId: widget.snap['commentId'],
      );
      if (res == 'success') {
        showSnackBar('Comment Deleted', context);
      } else {
        showSnackBar(res, context);
      }
    }

    return InkWell(
      onLongPress: () => showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              children: [
                SimpleDialogOption(
                  padding: const EdgeInsets.all(14),
                  child: const Text('Delete Comment'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteThis();
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
          }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Column(
          children: [
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    widget.snap.data()['profilePic'],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: widget.snap.data()['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                text: '${widget.snap.data()['text']}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat.yMMMd().format(
                              widget.snap.data()['datePublished'].toDate(),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: likeThisComment,
                      splashColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: widget.snap['likes'].contains(
                          AuthMethod().getCurrentUserId(),
                        )
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : Icon(Icons.favorite_border),
                      ),
                    ),
                    Text(
                      '${widget.snap['likes'].length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
