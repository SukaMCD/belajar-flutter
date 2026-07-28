import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF6366F1),
              child: const Icon(Icons.person_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('User Vibe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Halaman ini masih placeholder',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

