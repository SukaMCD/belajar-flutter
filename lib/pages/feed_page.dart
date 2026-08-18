import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';
import 'detail_page.dart';

enum SortOption { defaultOrder, titleAZ, titleZA, artistAZ, artistZA }

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  SortOption _sortOption = SortOption.defaultOrder;
  String _selectedCategory = 'All';

  List<Song> get _filteredAndSortedSongs {
   List<Song> songs = _selectedCategory == 'All'
   ? List<Song>.from(sampleSongs)
   : sampleSongs
   .where((song) => song.tag.toLowerCase() == _selectedCategory.toLowerCase())
   .toList();

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
      case SortOption.artistZA:
        songs.sort((a, b) => b.artist.compareTo(a.artist));
        break;
      case SortOption.defaultOrder:
        break;
    }
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    final songs = _filteredAndSortedSongs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Discover Vibes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) => setState(() => _sortOption = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortOption.defaultOrder,
                child: Text('Default'),
              ),
              PopupMenuItem(
                value: SortOption.titleAZ,
                child: Text('Title A-Z'),
              ),
              PopupMenuItem(
                value: SortOption.titleZA,
                child: Text('Title Z-A'),
              ),
              PopupMenuItem(
                value: SortOption.artistAZ,
                child: Text('Artist A-Z'),
              ),
              PopupMenuItem(
                value: SortOption.artistZA,
                child: Text('Artist Z-A'),
              ),
            ],
          ),
        ],
      ),
body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sampleTags.length,
              itemBuilder: (context, index) {
                final category = sampleTags[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6366F1),
                    backgroundColor: const Color(0xFF151922),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: songs.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada lagu untuk genre "$_selectedCategory"',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(song: song),
                            ),
                          );
                        },
                        child: SongCard(song: song),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}