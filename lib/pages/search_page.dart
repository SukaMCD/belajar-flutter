import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/song_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';

  List<Song> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return sampleSongs
        .where((song) =>
            song.title.toLowerCase().contains(q) ||
            song.artist.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search Vibes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _query = value),
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
              child: _query.isEmpty
                  ? Center(
                      child: Text('Type something to start searching',
                          style: TextStyle(color: Colors.grey[500])))
                  : results.isEmpty
                      ? Center(
                          child: Text('No results for "$_query"',
                              style: TextStyle(color: Colors.grey[500])))
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) =>
                              SongCard(song: results[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}