import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Discover Vibes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: sampleSongs.length,
        itemBuilder: (context, index) {
          return SongCard(song: sampleSongs[index]);
        },
      ),
    );
  }
}