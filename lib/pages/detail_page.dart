import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/song_model.dart';
import '../providers/audio_player_provider.dart';

const Color _accentBlue = Color(0xFF6366F1);

class DetailPage extends StatefulWidget {
  final Song song;
  final List<Song>? playlist;
  final int? initialIndex;

  const DetailPage({
    super.key,
    required this.song,
    this.playlist,
    this.initialIndex,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late List<Song> _playlist;
  YoutubePlayerController? _videoController;
  bool _showVideo = false;
  Song? _mvSong;
  int _mvRequestId = 0;

  @override
  void initState() {
    super.initState();

    _playlist = List<Song>.from(widget.playlist ?? const []);

    if (_playlist.isEmpty) {
      _playlist = [widget.song];
    }

    int initialIndex = widget.initialIndex ?? 0;

    if (initialIndex < 0 ||
        initialIndex >= _playlist.length ||
        _playlist[initialIndex].id != widget.song.id) {
      initialIndex = _playlist.indexWhere((song) => song.id == widget.song.id);
    }

    if (initialIndex == -1) {
      _playlist.insert(0, widget.song);
      initialIndex = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final audio = context.read<AudioPlayerProvider>();

      if (audio.currentSong?.id != _playlist[initialIndex].id) {
        audio.playSong(_playlist[initialIndex]);
      }
    });
  }

  @override
  void dispose() {
    _videoController?.close();
    super.dispose();
  }

  Future<void> _toggleMv(Song song) async {
    if (_showVideo) {
      final songToPlay = _mvSong ?? song;

      _closeMv();

      final audio = context.read<AudioPlayerProvider>();

      if (audio.currentSong?.id != songToPlay.id) {
        await audio.skipToSong(songToPlay);
      }

      return;
    }

    await _openMv(song);
  }

  Future<void> _openMv(Song song) async {
    final mediaUrl = song.mediaUrl.trim();
    if (mediaUrl.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL Music Video tidak valid atau belum tersedia.')),
      );
      return;
    }

    final videoId = YoutubePlayerController.convertUrlToId(mediaUrl);

    if (videoId == null || videoId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL Music Video tidak valid.')),
      );
      return;
    }

    final requestId = ++_mvRequestId;

    final audio = context.read<AudioPlayerProvider>();

    if (!_showVideo && audio.isPlaying) {
      await audio.togglePlayPause();
    }

    if (!mounted || requestId != _mvRequestId) return;

    final currentController = _videoController;

    if (currentController != null && _showVideo) {
      setState(() {
        _mvSong = song;
      });

      try {
        await currentController.loadVideoById(videoId: videoId);

        if (!mounted || requestId != _mvRequestId) return;

        await currentController.playVideo();
      } catch (e) {
        debugPrint('Gagal mengganti Music Video: $e');

        if (!mounted || requestId != _mvRequestId) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memutar Music Video. Coba lagi.'),
          ),
        );
      }

      return;
    }

    final newController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        strictRelatedVideos: true,
        enableJavaScript: true,
        playsInline: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );

    if (!mounted || requestId != _mvRequestId) {
      newController.close();
      return;
    }

    setState(() {
      _videoController = newController;
      _mvSong = song;
      _showVideo = true;
    });
  }

  void _closeMv() {
    _mvRequestId++;

    final oldController = _videoController;

    setState(() {
      _videoController = null;
      _mvSong = null;
      _showVideo = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController?.close();
    });
  }

  Future<void> _selectSong(Song song) async {
    if (_showVideo) {
      await _openMv(song);
      return;
    }

    await context.read<AudioPlayerProvider>().skipToSong(song);
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioPlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Now Playing',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: AspectRatio(
                    aspectRatio: _showVideo ? 16 / 9 : 1,
                    child: _showVideo && _videoController != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: YoutubePlayer(controller: _videoController!),
                          )
                        : _SongCoverWidget(playlist: _playlist),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              _SongInfoWidget(
                playlist: _playlist,
                showVideo: _showVideo,
                overrideSong: _showVideo ? _mvSong : null,
                onToggleMv: _toggleMv,
              ),

              const SizedBox(height: 22),

              _SongProgressBar(
                key: ValueKey(
                  _showVideo
                      ? 'video-${identityHashCode(_videoController)}'
                      : 'audio',
                ),
                audio: audio,
                videoController: _showVideo ? _videoController : null,
              ),

              const SizedBox(height: 14),

              RepaintBoundary(
                child: SizedBox(
                  height: 76,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: RepaintBoundary(
                          child: _PlaylistControlButton(
                            playlist: _playlist,
                            isNext: false,
                            selectedSongId: _showVideo ? _mvSong?.id : null,
                            onSongChanged: _selectSong,
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      SizedBox(
                        width: 76,
                        height: 76,
                        child: RepaintBoundary(
                          child: Center(
                            child: _PlayButtonWidget(
                              playlist: _playlist,
                              videoController: _showVideo
                                  ? _videoController
                                  : null,
                              onPlayOrPausePressed: (song) async {
                                if (audio.currentSong?.id != song.id) {
                                  await audio.playSong(song);
                                } else {
                                  await audio.togglePlayPause();
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      SizedBox(
                        width: 48,
                        height: 48,
                        child: RepaintBoundary(
                          child: _PlaylistControlButton(
                            playlist: _playlist,
                            isNext: true,
                            selectedSongId: _showVideo ? _mvSong?.id : null,
                            onSongChanged: _selectSong,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!_showVideo)
                Selector<AudioPlayerProvider, String?>(
                  selector: (_, audio) => audio.errorMessage,
                  builder: (context, errorMessage, _) {
                    if (errorMessage == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongCoverWidget extends StatelessWidget {
  final List<Song> playlist;

  const _SongCoverWidget({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerProvider, String?>(
      selector: (_, audio) => audio.currentSong?.imageUrl,
      builder: (context, imageUrl, _) {
        final url =
            imageUrl ?? (playlist.isNotEmpty ? playlist.first.imageUrl : '');

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: url.trim().isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF252525),
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        size: 90,
        color: Colors.white38,
      ),
    );
  }
}

class _SongInfoWidget extends StatelessWidget {
  final List<Song> playlist;
  final bool showVideo;
  final Song? overrideSong;
  final ValueChanged<Song> onToggleMv;

  const _SongInfoWidget({
    required this.playlist,
    required this.showVideo,
    required this.onToggleMv,
    this.overrideSong,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerProvider, Song?>(
      selector: (_, audio) => audio.currentSong,
      builder: (context, currentSong, _) {
        final song = overrideSong ?? currentSong ?? playlist.first;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 15),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => onToggleMv(song),
              tooltip: showVideo ? 'Tutup Music Video' : 'Putar Music Video',
              icon: Icon(
                showVideo ? Icons.album_rounded : Icons.ondemand_video_rounded,
                color: showVideo ? _accentBlue : Colors.white70,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayButtonWidget extends StatelessWidget {
  final List<Song> playlist;
  final YoutubePlayerController? videoController;
  final ValueChanged<Song> onPlayOrPausePressed;

  const _PlayButtonWidget({
    required this.playlist,
    required this.onPlayOrPausePressed,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    final controller = videoController;

    if (controller != null) {
      return YoutubeValueBuilder(
        controller: controller,
        builder: (context, value) {
          final playing = value.playerState == PlayerState.playing;
          final unavailable =
              value.playerState == PlayerState.unknown ||
              value.playerState == PlayerState.ended;

          return IconButton(
            onPressed: unavailable
                ? null
                : () async {
                    try {
                      if (playing) {
                        await controller.pauseVideo();
                      } else {
                        await controller.playVideo();
                      }
                    } catch (e) {
                      debugPrint('Gagal mengontrol MV: $e');
                    }
                  },
            iconSize: 68,
            color: _accentBlue,
            icon: Icon(
              playing
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
            ),
          );
        },
      );
    }

    return Selector<
      AudioPlayerProvider,
      ({bool isPlaying, bool isLoading, String? songId})
    >(
      selector: (_, audio) => (
        isPlaying: audio.isPlaying,
        isLoading: audio.isLoading,
        songId: audio.currentSong?.id,
      ),
      builder: (context, state, _) {
        final song = playlist.firstWhere(
          (item) => item.id == state.songId,
          orElse: () => playlist.first,
        );

        final showSpinner = state.isLoading && !state.isPlaying;

        return SizedBox(
          width: 76,
          height: 76,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 76, height: 76),
            onPressed: showSpinner
                ? null
                : () => onPlayOrPausePressed(song),
            iconSize: 68,
            color: _accentBlue,
            icon: showSpinner
                ? const SizedBox(
                    width: 35,
                    height: 35,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: _accentBlue,
                    ),
                  )
                : Icon(
                    state.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
          ),
        );
      },
    );
  }
}

class _PlaylistControlButton extends StatelessWidget {
  final List<Song> playlist;
  final bool isNext;
  final String? selectedSongId;
  final ValueChanged<Song> onSongChanged;

  const _PlaylistControlButton({
    required this.playlist,
    required this.isNext,
    required this.onSongChanged,
    this.selectedSongId,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerProvider, String?>(
      selector: (_, audio) => audio.currentSong?.id,
      builder: (context, currentSongId, _) {
        final activeSongId = selectedSongId ?? currentSongId;

        final currentIndex = playlist.indexWhere(
          (song) => song.id == activeSongId,
        );

        final hasMultiple = playlist.length > 1;
        final hasCurrentSong = currentIndex >= 0;

        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          onPressed: hasMultiple && hasCurrentSong
              ? () {
                  final targetIndex = isNext
                      ? (currentIndex + 1) % playlist.length
                      : (currentIndex - 1 + playlist.length) % playlist.length;

                  final targetSong = playlist[targetIndex];

                  onSongChanged(targetSong);
                }
              : null,
          iconSize: 36,
          color: Colors.white,
          disabledColor: Colors.white24,
          icon: Icon(
            isNext ? Icons.skip_next_rounded : Icons.skip_previous_rounded,
          ),
        );
      },
    );
  }
}

class _SongProgressBar extends StatefulWidget {
  final AudioPlayerProvider audio;
  final YoutubePlayerController? videoController;

  const _SongProgressBar({
    super.key,
    required this.audio,
    this.videoController,
  });

  @override
  State<_SongProgressBar> createState() => _SongProgressBarState();
}

class _SongProgressBarState extends State<_SongProgressBar> {
  bool _isDragging = false;
  bool _isSeeking = false;
  double _dragPosition = 0;
  int _seekRequestId = 0;
  double? _pendingVideoTarget;
  static const double _seekToleranceSeconds = 1.5;

  @override
  void didUpdateWidget(covariant _SongProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoController != widget.videoController) {
      _isDragging = false;
      _isSeeking = false;
      _dragPosition = 0;
      _pendingVideoTarget = null;
      _seekRequestId++;
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSeconds(double seconds) {
    if (!seconds.isFinite || seconds < 0) {
      return '0:00';
    }

    return _formatDuration(Duration(milliseconds: (seconds * 1000).round()));
  }

  Widget _buildSlider({
    required double max,
    required double value,
    required ValueChanged<double>? onChanged,
    required ValueChanged<double>? onChangeStart,
    required ValueChanged<double>? onChangeEnd,
  }) {
    final safeMax = max > 0 ? max : 1.0;

    final safeValue = value.clamp(0.0, safeMax).toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        activeTrackColor: _accentBlue,
        inactiveTrackColor: Colors.white24,
        thumbColor: _accentBlue,
        overlayColor: _accentBlue.withValues(alpha: 0.16),
      ),
      child: Slider(
        min: 0,
        max: safeMax,
        value: safeValue,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoController != null) {
      return _buildVideoProgress(widget.videoController!);
    }

    return _buildAudioProgress();
  }

  Widget _buildVideoProgress(YoutubePlayerController controller) {
    return YoutubeValueBuilder(
      controller: controller,
      builder: (context, value) {
        final duration = value.metaData.duration;
        final durationSeconds = duration.inMilliseconds / 1000.0;

        final hasDuration = durationSeconds.isFinite && durationSeconds > 0;

        final max = hasDuration ? durationSeconds : 1.0;

        return StreamBuilder<YoutubeVideoState>(
          stream: controller.videoStateStream,
          initialData: const YoutubeVideoState(),
          builder: (context, snapshot) {
            final videoState = snapshot.data;
            final actualPosition = videoState?.position ?? Duration.zero;

            final actualSeconds = actualPosition.inMilliseconds / 1000.0;

            final safeActualPosition =
                actualSeconds.isFinite && actualSeconds >= 0
                ? actualSeconds
                : 0.0;

            final clampedPosition = hasDuration
                ? safeActualPosition.clamp(0.0, max).toDouble()
                : safeActualPosition;


            double position;

            if (_isDragging) {
              position = _dragPosition;
            } else if (_pendingVideoTarget != null) {
              position = _pendingVideoTarget!;
            } else if (_isSeeking) {
              position = _dragPosition;
            } else {
              position = clampedPosition;
            }

            position = position.clamp(0.0, max).toDouble();


            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSlider(
                  max: max,
                  value: position,
                  onChangeStart: !hasDuration
                      ? null
                      : (value) {
                          setState(() {
                            _isDragging = true;
                            _isSeeking = false;
                            _dragPosition = value;
                          });
                        },
                  onChanged: !hasDuration
                      ? null
                      : (value) {
                          setState(() {
                            _dragPosition = value;
                          });
                        },
                  onChangeEnd: !hasDuration
                      ? null
                      : (value) {
                          _seekVideo(
                            controller: controller,
                            targetSeconds: value,
                            durationSeconds: max,
                          );
                        },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatSeconds(position),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatSeconds(hasDuration ? durationSeconds : 0),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _seekVideo({
    required YoutubePlayerController controller,
    required double targetSeconds,
    required double durationSeconds,
  }) async {
    final requestId = ++_seekRequestId;

    final target = targetSeconds.clamp(0.0, durationSeconds).toDouble();

    setState(() {
      _isDragging = false;
      _isSeeking = true;
      _dragPosition = target;
      _pendingVideoTarget = target;
    });

    try {
      await controller.seekTo(seconds: target, allowSeekAhead: true);

      if (!mounted ||
          requestId != _seekRequestId ||
          controller != widget.videoController) {
        return;
      }

      final deadline = DateTime.now().add(const Duration(seconds: 5));

      while (mounted &&
          requestId == _seekRequestId &&
          controller == widget.videoController &&
          DateTime.now().isBefore(deadline)) {
        final state = await controller.videoStateStream.first.timeout(
          const Duration(milliseconds: 700),
          onTimeout: () => const YoutubeVideoState(),
        );

        if (!mounted || requestId != _seekRequestId) {
          return;
        }

        final reportedSeconds = state.position.inMilliseconds / 1000.0;

        if (reportedSeconds.isFinite &&
            reportedSeconds >= 0 &&
            (reportedSeconds - target).abs() <= _seekToleranceSeconds) {
          break;
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('Gagal seek MV: $e');
    } finally {
      if (mounted &&
          requestId == _seekRequestId &&
          controller == widget.videoController) {
        setState(() {
          _isSeeking = false;
          _pendingVideoTarget = null;
        });
      }
    }
  }

  Widget _buildAudioProgress() {
    return StreamBuilder<Duration?>(
      stream: widget.audio.player.durationStream,
      initialData: widget.audio.player.duration,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;

        final maxMs = duration.inMilliseconds > 0
            ? duration.inMilliseconds.toDouble()
            : 1.0;

        return StreamBuilder<Duration>(
          stream: widget.audio.player.positionStream,
          initialData: widget.audio.player.position,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;

            final positionMs = position.inMilliseconds.toDouble();

            final currentPosition = _isDragging || _isSeeking
                ? _dragPosition
                : positionMs;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSlider(
                  max: maxMs,
                  value: currentPosition,
                  onChangeStart: duration.inMilliseconds <= 0
                      ? null
                      : (value) {
                          setState(() {
                            _isDragging = true;
                            _dragPosition = value;
                          });
                        },
                  onChanged: duration.inMilliseconds <= 0
                      ? null
                      : (value) {
                          setState(() {
                            _dragPosition = value;
                          });
                        },
                  onChangeEnd: duration.inMilliseconds <= 0
                      ? null
                      : (value) async {
                          setState(() {
                            _isDragging = false;
                            _isSeeking = true;
                            _dragPosition = value;
                          });

                          try {
                            await widget.audio.seek(
                              Duration(milliseconds: value.round()),
                            );
                          } catch (e) {
                            debugPrint('Gagal seek audio: $e');
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSeeking = false;
                              });
                            }
                          }
                        },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(
                          Duration(milliseconds: currentPosition.round()),
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
