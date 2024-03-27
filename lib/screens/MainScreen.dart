import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inst_clone/utils/ScreensUtils.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPage = 0;

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: screensUtils,
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        border: const Border(top: BorderSide.none),
        currentIndex: _currentPage,
        onTap: (Page) {
          setState(() {
            _currentPage = Page;
            _pageController.jumpToPage(Page);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _currentPage == 0
                ? const Icon(
                    Icons.home,
                    color: Colors.black,
                  )
                : const Icon(
                    Icons.home_outlined,
                  ),
          ),
          BottomNavigationBarItem(
            icon: _currentPage == 1
                ? const Icon(
                    Icons.search,
                    color: Colors.black,
                  )
                : const Icon(
                    Icons.search_rounded,
                  ),
          ),
          BottomNavigationBarItem(
            icon: _currentPage == 2
                ? const Icon(
                    Icons.add_circle,
                    color: Colors.black,
                  )
                : const Icon(
                    Icons.add_outlined,
                  ),
          ),
          BottomNavigationBarItem(
            icon: _currentPage == 3
                ? const Icon(
                    Icons.person_2,
                    color: Colors.black,
                  )
                : const Icon(
                    Icons.person_2_outlined,
                  ),
          ),
        ],
      ),
    );
  }
}
