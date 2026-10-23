import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<Song> _filterAndSortSongs(List<Song> sourceSongs) {
    List<Song> songs = _selectedCategory == 'All'
        ? List<Song>.from(sourceSongs)
        : sourceSongs
            .where((song) =>
                song.tag.toLowerCase() == _selectedCategory.toLowerCase())
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

  Future<void> _seedSampleData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final song in sampleSongs) {
        final docRef =
            FirebaseFirestore.instance.collection('songs').doc(song.id);
        batch.set(docRef, song.toMap());
      }
      await batch.commit();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Berhasil mengunggah sample lagu ke Cloud Firestore!'),
          backgroundColor: Color(0xFF6366F1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah data: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
        actions: [
          IconButton(
            tooltip: 'Upload Sample Lagu ke Firestore',
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: _seedSampleData,
          ),
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('songs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data dari Firestore:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final allSongs = docs
              .map((doc) => Song.fromFirestore(doc.data(), doc.id))
              .toList();

          return Column(
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
                child: docs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.library_music_outlined,
                                  size: 64, color: Colors.grey[600]),
                              const SizedBox(height: 16),
                              const Text(
                                'Koleksi Firestore "songs" masih kosong',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tekan tombol di bawah untuk mengunggah contoh lagu ke Firestore.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _seedSampleData,
                                icon: const Icon(Icons.cloud_upload_rounded),
                                label: const Text('Upload Data Contoh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : () {
                        final filteredSongs = _filterAndSortSongs(allSongs);
                        if (filteredSongs.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada lagu untuk genre "$_selectedCategory"',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(song: song),
                                  ),
                                );
                              },
                              child: SongCard(
                                song: song,
                                playlist: filteredSongs,
                              ),
                            );
                          },
                        );
                      }(),
              ),
            ],
          );
        },
      ),
    );
  }
}