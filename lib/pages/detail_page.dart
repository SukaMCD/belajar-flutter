import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class DetailPage extends StatefulWidget {
  final Song song;

  const DetailPage({super.key, required this.song});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.song.audioUrl);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    widget.song.coverUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              widget.song.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.song.artist,
              style: TextStyle(fontSize: 15, color: Colors.grey[400]),
            ),
            const Spacer(),

            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayer.duration ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds.toDouble().clamp(
                        0.0,
                        duration.inSeconds.toDouble() > 0
                            ? duration.inSeconds.toDouble()
                            : 1.0,
                      ),
                      max: duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1.0,
                      activeColor: const Color(0xFF6366F1),
                      inactiveColor: Colors.white10,
                      onChanged: (v) {
                        _audioPlayer.seek(Duration(seconds: v.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            position.toString().split('.').first,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            duration.toString().split('.').first,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 36),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),

                // Tombol Play/Pause dengan State
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF6366F1),
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (playing != true) {
                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF6366F1),
                        child: IconButton(
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                          onPressed: _audioPlayer.play,
                        ),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF6366F1),
                        child: IconButton(
                          icon: const Icon(
                            Icons.pause_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                          onPressed: _audioPlayer.pause,
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 36),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}