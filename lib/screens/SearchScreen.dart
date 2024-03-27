import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inst_clone/screens/ProfileScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool isShowUser = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(
          Icons.search,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a User',
          ),
          onTapOutside: (_) {
            setState(() {
              // isShowUser = false;
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            });
          },
          onSubmitted: (String _) {
            setState(() {
              isShowUser = true;
            });
          },
          onTap: () {
            setState(() {
              isShowUser = true;
            });
          },
        ),
      ),
      body: isShowUser
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('username',
                      isGreaterThanOrEqualTo: _searchController.text)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as dynamic).docs[index]['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['photoUrl'],
                          ),
                        ),
                        title: Text((snapshot.data! as dynamic).docs[index]
                            ['username']),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: StaggeredGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    children: List.generate(
                      (snapshot.data! as dynamic).docs.length,
                      (index) => StaggeredGridTile.count(
                        crossAxisCellCount: (index % 7 == 0) ? 2 : 1,
                        mainAxisCellCount: (index % 7 == 0) ? 2 : 1,
                        child: Image.network(
                          (snapshot.data as dynamic).docs[index]['postUrl'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
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
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
