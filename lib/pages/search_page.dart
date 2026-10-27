import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _songsStream;

  @override
  void initState() {
    super.initState();
    _songsStream = FirebaseFirestore.instance.collection('songs').snapshots();
  }

  List<Song> _searchSongs(List<Song> allSongs) {
    if (_query.trim().isEmpty) {
      return [];
    }

    final query = _query.trim().toLowerCase();

    return allSongs.where((song) {
      final title = song.title.toLowerCase();
      final artist = song.artist.toLowerCase();

      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Search Vibes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: 'Search titles or artists...',

                hintStyle: TextStyle(color: Colors.grey[500]),

                prefixIcon: const Icon(Icons.search_rounded),

                filled: true,
                fillColor: const Color(0xFF151922),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _songsStream,

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Gagal mengambil data dari Firebase'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366F1),
                      ),
                    );
                  }

                  final allSongs = snapshot.data!.docs
                      .map((doc) => Song.fromFirestore(doc))
                      .toList();

                  final results = _searchSongs(allSongs);

                  if (_query.trim().isEmpty) {
                    return Center(
                      child: Text(
                        'Type something to start searching',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }

                  if (results.isEmpty) {
                    return Center(
                      child: Text(
                        'No results for "$_query"',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: results.length,

                    itemBuilder: (context, index) {
                      return SongCard(
                        song: results[index],

                        playlist: results,

                        initialIndex: index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}