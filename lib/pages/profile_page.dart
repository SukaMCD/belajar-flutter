import 'package:belajar_flutter/models/song_model.dart';
import 'package:belajar_flutter/pages/favorite_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final List<Song> favoriteSongs;
  final void Function(Song)? onFavoriteToggle;

  const ProfilePage({
    super.key,
    required this.favoriteSongs,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF6366F1),
              backgroundImage: const AssetImage('lib/assets/aaa.jpg'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fabian Rizky Pratama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Music Enthusiast',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${favoriteSongs.length}', 'Liked'),
                  Container(width: 1, height: 24, color: Colors.white10),
                  _buildStatItem('24h', 'Streamed'),
                  Container(width: 1, height: 24, color: Colors.white10),
                  _buildStatItem('5', 'Playlist'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              Icons.favorite_rounded,
              'Favorite Song',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      favoriteSongs: favoriteSongs,
                      onFavoriteToggle: onFavoriteToggle,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(Icons.history_rounded, 'Recently Played'),
            _buildMenuItem(Icons.storage_rounded, 'Clear Cache Data'),
            _buildMenuItem(Icons.settings_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }
}

Widget _buildStatItem(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6366F1),
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}

Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF151922),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white10),
    ),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF6366F1), size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    ),
  );
}
