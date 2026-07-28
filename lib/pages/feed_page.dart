import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';

enum SortOption { defaultOrder, titleAZ, titleZA, artistAZ }

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  SortOption _sortOption = SortOption.defaultOrder;

  List<Song> get _sortedSongs {
    final songs = List<Song>.from(sampleSongs);
    switch (_sortOption) {
      case SortOption.titleAZ:
        songs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleZA:
        songs.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.artistAZ:
        songs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case SortOption.defaultOrder:
        break;
    }
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    final songs = _sortedSongs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Discover Vibes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) => setState(() => _sortOption = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: SortOption.defaultOrder, child: Text('Default')),
              PopupMenuItem(value: SortOption.titleAZ, child: Text('Title A-Z')),
              PopupMenuItem(value: SortOption.titleZA, child: Text('Title Z-A')),
              PopupMenuItem(value: SortOption.artistAZ, child: Text('Artist A-Z')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: songs.length,
        itemBuilder: (context, index) => SongCard(song: songs[index]),
      ),
    );
  }
}