import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/favorite_provider.dart';
import 'favorite_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final List<Song> allSongs;

  const ProfilePage({super.key, required this.allSongs});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditProfileDialog() {
    final user = FirebaseAuth.instance.currentUser;

    final nameController = TextEditingController(text: user?.displayName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),

        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),

          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();

              if (newName.isEmpty) return;

              try {
                await user?.updateDisplayName(newName);
                await FirebaseAuth.instance.currentUser?.reload();
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                setState(() {});
              } catch (e) {
                if (!ctx.mounted) return;

                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Gagal memperbarui nama: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();

    final likedCount = favProvider.favoriteIds.length;

    final currentUser = FirebaseAuth.instance.currentUser;

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
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFF6366F1),
              child: Icon(Icons.person_rounded, size: 48, color: Colors.white),
            ),

            const SizedBox(height: 16),

            Text(
              currentUser?.displayName ?? 'User Test',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              currentUser?.email ?? 'Music Enthusiast',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF151922),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('$likedCount', 'Liked'),

                  Container(height: 24, width: 1, color: Colors.white10),

                  _buildStatItem('24h', 'Streamed'),

                  Container(height: 24, width: 1, color: Colors.white10),

                  _buildStatItem('3', 'Playlists'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildMenuItem(
              Icons.favorite_rounded,
              'Favorite Songs',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(
                      allSongs: widget.allSongs,
                    ),
                  ),
                );
              },
            ),

            _buildMenuItem(Icons.history_rounded, 'Recently Played'),

            _buildMenuItem(Icons.storage_rounded, 'Clear Cache Data'),

            _buildMenuItem(
              Icons.edit_rounded,
              'Edit Profile',
              onTap: _showEditProfileDialog,
            ),

            _buildMenuItem(Icons.settings_rounded, 'Settings'),

            const SizedBox(height: 8),

            _buildMenuItem(
              Icons.logout_rounded,
              'Logout',
              isDanger: true,

              onTap: _logout,
            ),
          ],
        ),
      ),
    );
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

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    final iconColor = isDanger ? Colors.redAccent : const Color(0xFF6366F1);

    final textColor = isDanger ? Colors.redAccent : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDanger ? Colors.redAccent.withAlpha(50) : Colors.white10,
        ),
      ),

      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),

        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),

        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDanger ? Colors.redAccent.withAlpha(150) : Colors.grey,
        ),

        onTap: onTap,
      ),
    );
  }
}
