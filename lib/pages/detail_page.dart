import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

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
  late AudioPlayer _audioPlayer;
  late List<Song> _playlist;
  late int _currentIndex;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playlist = widget.playlist ?? sampleSongs;
    _currentIndex = _playlist.indexWhere((s) => s.id == widget.song.id);
    if (_currentIndex == -1) {
      _playlist = [widget.song];
      _currentIndex = 0;
    }

    _loadAndPlaySong();

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextSong();
      }
    });
  }

  Future<void> _loadAndPlaySong() async {
    try {
      final currentSong = _playlist[_currentIndex];
      final url = currentSong.audioUrl;
      await _audioPlayer.stop();
      if (url.startsWith('http://') || url.startsWith('https://')) {
        await _audioPlayer.setUrl(url);
      } else {
        await _audioPlayer.setAsset(url);
      }
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  void _playNextSong() {
    if (_playlist.isEmpty) return;
    setState(() {
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
    _loadAndPlaySong();
  }

  void _playPreviousSong() {
    if (_playlist.isEmpty) return;
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _playlist.length - 1;
      }
    });
    _loadAndPlaySong();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _playlist[_currentIndex];

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
              tag: 'cover_${currentSong.id}',
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
                    currentSong.coverUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              currentSong.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              currentSong.artist,
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
                  onPressed: _playPreviousSong,
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
                  onPressed: _playNextSong,
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