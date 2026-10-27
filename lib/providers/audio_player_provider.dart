import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Song? _currentSong;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isLoading = false;
  bool _lastPlayingState = false;

  String? _errorMessage;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  int _loadRequestId = 0;

  AudioPlayerProvider() {
    _positionSubscription = _player.positionStream.listen((position) {
      _position = position;
    });

    _durationSubscription = _player.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
    });

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _position = _duration;
      }

      final isPlayingNow = state.playing;

      if (_lastPlayingState != isPlayingNow) {
        _lastPlayingState = isPlayingNow;
        notifyListeners();
      }
    });
  }

  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _player.playing;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Duration get position => _position;
  Duration get duration => _duration;

  Future<void> playSong(Song song) async {
    if (_currentSong?.id == song.id) {
      await togglePlayPause();
      return;
    }

    await _loadAndPlaySong(song);
  }

  Future<void> skipToSong(Song song) async {
    if (song.audioUrl.trim().isEmpty) {
      _errorMessage = 'Path audio belum diisi.';
      notifyListeners();
      return;
    }

    await _loadAndPlaySong(song);
  }

  Future<void> _loadAndPlaySong(Song song) async {
    if (song.audioUrl.trim().isEmpty) {
      _errorMessage = 'Path audio belum diisi.';
      notifyListeners();
      return;
    }

    final requestId = ++_loadRequestId;

    _currentSong = song;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final audioPath = song.audioUrl.trim();

      if (audioPath.startsWith('http://') || audioPath.startsWith('https://')) {
        await _player.setUrl(audioPath);
      } else {
        final assetPath = audioPath.startsWith('assets/')
            ? audioPath.substring('assets/'.length)
            : audioPath;

        await _player.setAsset(assetPath);
      }

      if (requestId != _loadRequestId) return;

      _duration = _player.duration ?? Duration.zero;
      _position = Duration.zero;
      _isLoading = false;

      notifyListeners();
      unawaited(_startPlayback(requestId));
    } catch (error, stackTrace) {
      debugPrint('AUDIO LOAD ERROR: $error');
      debugPrint('$stackTrace');

      if (requestId != _loadRequestId) return;

      _errorMessage = 'Gagal memuat lagu: $error';
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> _startPlayback(int requestId) async {
    try {
      await _player.play();
    } catch (error, stackTrace) {
      debugPrint('AUDIO PLAY ERROR: $error');
      debugPrint('$stackTrace');

      if (requestId != _loadRequestId) return;

      _errorMessage = 'Gagal memutar audio: $error';

      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_isLoading) return;

      if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }

        unawaited(_startPlayback(_loadRequestId));
      }
    } catch (error, stackTrace) {
      debugPrint('AUDIO CONTROL ERROR: $error');
      debugPrint('$stackTrace');

      _errorMessage = 'Gagal mengontrol audio: $error';

      notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    if (_duration <= Duration.zero) return;

    final targetMilliseconds = position.inMilliseconds.clamp(
      0,
      _duration.inMilliseconds,
    );

    final target = Duration(milliseconds: targetMilliseconds);

    try {
      await _player.seek(target);

      _position = target;
    } catch (error, stackTrace) {
      debugPrint('AUDIO SEEK ERROR: $error');
      debugPrint('$stackTrace');

      _errorMessage = 'Gagal mengubah posisi lagu: $error';

      notifyListeners();
    }
  }

  Future<void> stopSong() async {
    _loadRequestId++;

    await _player.stop();

    _currentSong = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _isLoading = false;
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();

    super.dispose();
  }
}
