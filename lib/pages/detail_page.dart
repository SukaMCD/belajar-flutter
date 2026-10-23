import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_player_provider.dart';

class DetailPage extends StatefulWidget {
  final Song song;
  final List<Song>? playlist;

  const DetailPage({
    super.key,
    required this.song,
    this.playlist,
  });
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioPlayerProvider>().playSong(widget.song);
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final player = audioProvider.player;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Now Playing', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Hero(
              tag: 'cover_${widget.song.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Builder(
                  builder: (context) {
                    final url = widget.song.coverUrl.trim();
                    Widget placeholder = Container(
                      height: 300,
                      width: double.infinity,
                      color: const Color(0xFF1E1B4B),
                      child: const Icon(Icons.music_note_rounded,
                          size: 64, color: Colors.white54),
                    );

                    if (url.startsWith('http://') ||
                        url.startsWith('https://')) {
                      return Image.network(
                        url,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => placeholder,
                      );
                    } else if (url.isNotEmpty) {
                      return Image.asset(
                        url,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => placeholder,
                      );
                    }
                    return placeholder;
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(widget.song.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.song.artist, style: TextStyle(fontSize: 15, color: Colors.grey[400])),
            const Spacer(),

            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                // Pastikan duration minimal 1.0 jika belum ter-load (0)
                final durationSec = (player.duration?.inSeconds.toDouble() ?? 0.0);
                final maxDuration = durationSec > 0 ? durationSec : 1.0;

                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds.toDouble().clamp(0.0, maxDuration),
                      max: maxDuration,
                      activeColor: const Color(0xFF6366F1),
                      inactiveColor: Colors.white10,
                      onChanged: (v) => audioProvider.seek(Duration(seconds: v.toInt())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(position.toString().split('.').first, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          Text((player.duration ?? Duration.zero).toString().split('.').first, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF6366F1),
                  child: IconButton(
                    icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 34, color: Colors.white),
                    onPressed: audioProvider.togglePlayPause,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
