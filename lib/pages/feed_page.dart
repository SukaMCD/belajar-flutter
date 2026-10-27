import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/song_card.dart';
import 'detail_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // [BARU]
  // Stream untuk mendengarkan data lagu dari koleksi Firestore "songs".
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _songsStream;

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    // [BARU]
    // Mengambil snapshot koleksi "songs" secara real-time.
    // Perubahan dokumen pada koleksi ini dapat menghasilkan snapshot baru.
    _songsStream = FirebaseFirestore.instance.collection('songs').snapshots();
  }

  // [BARU]
  // Method ini memusatkan proses navigasi menuju DetailPage.
  // Lagu, playlist, dan indeks awal dikirim ke halaman detail.
  void _openDetail({
    required Song song,
    required List<Song> playlist,
    required int initialIndex,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          song: song,
          playlist: playlist,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // [BARU]
  // Menentukan playlist dan indeks yang tepat untuk lagu aktif.
  void _openCurrentSong({
    required Song currentSong,
    required List<Song> filteredSongs,
  }) {
    // Cari posisi lagu aktif di dalam playlist hasil filter.
    final filteredIndex = filteredSongs.indexWhere(
      (song) => song.id == currentSong.id,
    );

    // Jika lagu ditemukan, buka detail dengan playlist kategori aktif.
    if (filteredIndex >= 0) {
      _openDetail(
        song: currentSong,
        playlist: filteredSongs,
        initialIndex: filteredIndex,
      );

      return;
    }

    // [BARU]
    // Jika lagu aktif tidak ada dalam kategori yang sedang dipilih,
    // gunakan playlist berisi satu lagu agar indeksnya tetap valid.
    _openDetail(song: currentSong, playlist: [currentSong], initialIndex: 0);
  }

  // [PERUBAHAN]
  // Mini player dipisahkan menjadi method tersendiri agar struktur
  // build() utama lebih mudah dibaca.
  Widget _buildMiniPlayer(List<Song> filteredSongs) {
    // Consumer mendengarkan perubahan AudioPlayerProvider.
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, _) {
        final currentSong = audioProvider.currentSong;

        // Sembunyikan mini player jika belum ada lagu yang dipilih.
        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(12),

          // Tampilan mini player.
          decoration: BoxDecoration(
            color: const Color(0xFF202536),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),

          child: Row(
            children: [
              // [PERUBAHAN]
              // Menggunakan imageUrl sesuai model Song terbaru.
              // Jika URL kosong atau gambar gagal dimuat,
              // tampilkan ikon musik sebagai pengganti.
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: currentSong.imageUrl.trim().isNotEmpty
                    ? Image.network(
                        currentSong.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                          );
                        },
                      )
                    : const Icon(Icons.music_note_rounded, color: Colors.white),
              ),

              const SizedBox(width: 12),

              // [BARU]
              // Judul dan artis bisa diketuk untuk membuka DetailPage.
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _openCurrentSong(
                      currentSong: currentSong,
                      filteredSongs: filteredSongs,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentSong.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        currentSong.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              // [PERUBAHAN]
              // Menggunakan state dari AudioPlayerProvider.
              // Saat loading, ikon berubah menjadi ikon proses loading.
              IconButton(
                tooltip: audioProvider.isPlaying ? 'Pause' : 'Play',
                onPressed: () async {
                  // Jangan jalankan kontrol ketika audio sedang dimuat.
                  if (audioProvider.isLoading) return;

                  await audioProvider.togglePlayPause();
                },
                icon: Icon(
                  audioProvider.isLoading
                      ? Icons.hourglass_top_rounded
                      : audioProvider.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: const Color(0xFF818CF8),
                  size: 28,
                ),
              ),

              // [BARU]
              // Membuka halaman pemutar secara langsung.
              IconButton(
                tooltip: 'Buka pemutar',
                onPressed: () {
                  _openCurrentSong(
                    currentSong: currentSong,
                    filteredSongs: filteredSongs,
                  );
                },
                icon: const Icon(
                  Icons.open_in_full_rounded,
                  color: Color(0xFF818CF8),
                ),
              ),

              // Menghentikan audio dan menghapus lagu aktif dari provider.
              IconButton(
                tooltip: 'Hentikan lagu',
                onPressed: () async {
                  await audioProvider.stopSong();
                },
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Music Vibes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
      ),

      // [BARU]
      // StreamBuilder menangani status pengambilan data dari Firestore.
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _songsStream,
        builder: (context, snapshot) {
          // Jika pengambilan data gagal, tampilkan pesan error.
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data dari Firebase.'),
            );
          }

          // Jika data belum tersedia, tampilkan indikator loading.
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          // [PERUBAHAN]
          // Mengubah setiap dokumen Firestore menjadi objek Song.
          // Sebelumnya, daftar lagu diambil dari sampleSongs.
          final songs = snapshot.data!.docs
              .map((doc) => Song.fromFirestore(doc))
              .toList();

          // [PERUBAHAN]
          // Filter dilakukan pada daftar lagu yang diterima dari Firebase.
          // Kategori "All" menampilkan seluruh lagu.
          final filteredSongs = _selectedCategory == 'All'
              ? songs
              : songs
                    .where(
                      (song) =>
                          song.tag.toLowerCase() ==
                          _selectedCategory.toLowerCase(),
                    )
                    .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Temukan musik favoritmu',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ),

              // FILTER KATEGORI
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Membuat ChoiceChip berdasarkan daftar categories.
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,

                          // [PERUBAHAN]
                          // Memperbarui kategori aktif ketika chip dipilih.
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },

                          selectedColor: const Color(0xFF6366F1),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              // DAFTAR LAGU
              Expanded(
                child: filteredSongs.isEmpty
                    ? Center(
                        child: Text(
                          // Bedakan kondisi koleksi kosong dan kategori kosong.
                          songs.isEmpty
                              ? 'Belum ada lagu di Firebase.'
                              : 'Tidak ada lagu pada kategori ini.',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];

                          // [PERUBAHAN]
                          // Setiap kartu menerima lagu, playlist hasil filter,
                          // dan indeks lagu dalam playlist tersebut.
                          return SongCard(
                            song: song,
                            playlist: filteredSongs,
                            initialIndex: index,
                          );
                        },
                      ),
              ),

              // [PERUBAHAN]
              // Mini player ditampilkan di bagian bawah halaman.
              // Jika tidak ada lagu aktif, widget ini tidak ditampilkan.
              _buildMiniPlayer(filteredSongs),
            ],
          );
        },
      ),
    );
  }
}