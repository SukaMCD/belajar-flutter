import 'package:flutter/material.dart';
import 'package:belajar_flutter/models/song_model.dart';
import 'package:belajar_flutter/widgets/song_card.dart';

class FavoritePage extends StatelessWidget {
  final List<Song> favoriteSongs;
  final void Function(Song)? onFavoriteToggle;

  const FavoritePage({
    super.key,
    required this.favoriteSongs,
    this.onFavoriteToggle,
  });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Favorite Songs (${favoriteSongs.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: favoriteSongs.isEmpty

          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada lagu favorit',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            )

          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SongCard(
                    song: song,
                    isFavorite: true,
                    onFavoriteToggle: () => onFavoriteToggle?.call(song),
                  ),
                );
              },
            ),
    );
  }
}