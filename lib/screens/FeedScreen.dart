import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inst_clone/widgets/PostCardWidget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 54,
          title: SvgPicture.asset(
            'assets/instagram_title.svg',
            height: 54,
            alignment: Alignment.bottomCenter,
          ),
          centerTitle: false,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('datePublished', descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => PostCardWidget(
                snap: snapshot.data!.docs[index].data(),
              ),
            );
          },
        ),
      ),
    );
  }
}
