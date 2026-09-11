import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Song? _currentSong;

  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _player.playing;

  Future<void> playSong(Song song) async {
    // Jika lagu yang sama masih diputar, tidak perlu setUrl ulang
    if (_currentSong?.id == song.id) {
      // Jika lagunya sedang di-pause, kita play lagi
      if (!_player.playing) _player.play();
      return;
    }

    try {
      _currentSong = song;
      await _player.setUrl(song.audioUrl);
      await _player.play();
      
      // Notify setelah URL di-set dan play dipanggil, agar UI update
      notifyListeners(); 
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  void togglePlayPause() {
    _player.playing ? _player.pause() : _player.play();
    // Tidak perlu notifyListeners di sini karena UI DetailPage 
    // sudah menggunakan StreamBuilder untuk playerStateStream
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

