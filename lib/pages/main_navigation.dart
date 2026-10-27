import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';
import 'feed_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _songsStream;

  @override
  void initState() {
    super.initState();

    _songsStream = FirebaseFirestore.instance.collection('songs').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _songsStream,
      builder: (context, snapshot) {
        final List<Song> allSongs = snapshot.hasData
            ? snapshot.data!.docs.map((doc) => Song.fromFirestore(doc)).toList()
            : [];

        final List<Widget> pages = [
          const FeedPage(),
          const SearchPage(),

          ProfilePage(allSongs: allSongs),
        ];

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: pages),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,

            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },

            backgroundColor: const Color(0xFF151922),
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: Colors.grey[500],
            type: BottomNavigationBarType.fixed,

            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}