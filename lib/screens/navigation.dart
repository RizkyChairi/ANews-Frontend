import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'home_page.dart';
import 'create_page.dart';
import 'myblog_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CreatePage(),
    const MyBlogPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              selectedColor: Colors.green,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.add_circle_outline),
              title: const Text('Create'),
              selectedColor: Colors.green,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.article_outlined),
              title: const Text('My Blog'),
              selectedColor: Colors.green,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              selectedColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}