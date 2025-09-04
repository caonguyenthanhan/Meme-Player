import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/media_file.dart';
import '../models/app_settings.dart';
import '../services/window_service.dart';
import '../widgets/playback_speed_control.dart';
import '../widgets/subtitle_control.dart';
import '../widgets/preset_speed_buttons.dart';
import '../services/subtitle_service.dart';

class PlayerScreen extends StatefulWidget {
  final MediaFile mediaFile;
  final List<MediaFile>? playlist;
  final int? initialIndex;

  const PlayerScreen({super.key, required this.mediaFile, this.playlist, this.initialIndex});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _showControls = true;
  String? _errorMessage;
  final WindowService _windowService = WindowService();
  final SubtitleService _subtitleService = SubtitleService();
  String? _currentSubtitleText;
  late VoidCallback _positionListener;
  List<MediaFile>? _playlist;
  int _currentIndex = 0;

  MediaFile get _currentMedia => (_playlist != null && _playlist!.isNotEmpty)
      ? _playlist![_currentIndex]
      : widget.mediaFile;

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
    _currentIndex = widget.initialIndex ?? 0;
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final file = File(_currentMedia.path);
      if (!file.existsSync()) {
        setState(() {
          _errorMessage = 'Tệp không tồn tại: ${_currentMedia.path}';
        });
        return;
      }

      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();

      // Load subtitles if present
      if (_currentMedia.subtitlePath != null) {
        await _subtitleService.loadSubtitleFromFile(_currentMedia.subtitlePath!);
      }

      // Get playback speed from settings
      final settings = Provider.of<AppSettings>(context, listen: false);
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        playbackSpeeds: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
        playbackSpeed: settings.playbackSpeed,
        subtitle: null,
      );

      setState(() {
        _isInitialized = true;
      });

      // Listen to position updates for subtitle rendering
      _positionListener = () {
        final position = _videoPlayerController!.value.position;
        final speed = _chewieController?.playbackSpeed ?? 1.0;
        if (_currentMedia.subtitlePath != null) {
          final text = _subtitleService.getSubtitleTextAtPosition(
            _currentMedia.subtitlePath!,
            position,
            speed,
          );
          if (text != _currentSubtitleText) {
            setState(() {
              _currentSubtitleText = text;
            });
          }
        }
      };
      _videoPlayerController!.addListener(_positionListener);
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi khởi tạo trình phát: $e';
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  bool get _hasNext => _playlist != null && _currentIndex < (_playlist!.length - 1);
  bool get _hasPrev => _playlist != null && _currentIndex > 0;

  Future<void> _playAtIndex(int index) async {
    if (_playlist == null || index < 0 || index >= _playlist!.length) return;
    if (_videoPlayerController != null) {
      _videoPlayerController!.removeListener(_positionListener);
      await _videoPlayerController!.pause();
      await _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
    if (_chewieController != null) {
      await _chewieController!.pause();
      await _chewieController!.dispose();
      _chewieController = null;
    }
    _subtitleService.clearLoadedSubtitles();
    setState(() {
      _currentSubtitleText = null;
      _isInitialized = false;
      _errorMessage = null;
      _currentIndex = index;
    });
    await _initializePlayer();
  }

  Future<void> _playNext() async {
    if (_hasNext) {
      await _playAtIndex(_currentIndex + 1);
    }
  }

  Future<void> _playPrev() async {
    if (_hasPrev) {
      await _playAtIndex(_currentIndex - 1);
    }
  }

  void _skipForward(Duration duration) {
    if (_videoPlayerController != null) {
      final currentPosition = _videoPlayerController!.value.position;
      final newPosition = currentPosition + duration;
      _videoPlayerController!.seekTo(newPosition);
    }
  }

  void _skipBackward(Duration duration) {
    if (_videoPlayerController != null) {
      final currentPosition = _videoPlayerController!.value.position;
      final newPosition = currentPosition - duration;
      _videoPlayerController!.seekTo(newPosition);
    }
  }

  void _setPlaybackSpeed(double speed) {
    if (_chewieController != null) {
      setState(() {
        _chewieController!.setPlaybackSpeed(speed);
      });
      
      // Save to settings
      final settings = Provider.of<AppSettings>(context, listen: false);
      settings.setPlaybackSpeed(speed);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _seekToPosition(double position) {
    if (_videoPlayerController != null) {
      final duration = _videoPlayerController!.value.duration;
      if (duration > Duration.zero) {
        final seekPosition = duration * position;
        _videoPlayerController!.seekTo(seekPosition);
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    if (_videoPlayerController != null) {
      _videoPlayerController!.removeListener(_positionListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_currentMedia.name),
          actions: [
            if (_playlist != null)
              IconButton(
                icon: const Icon(Icons.skip_previous),
                tooltip: 'Trước đó',
                onPressed: _hasPrev ? _playPrev : null,
              ),
            // Nút Always on top
            IconButton(
              icon: Icon(
                Icons.pin_drop,
                color: _windowService.isAlwaysOnTop ? Colors.amber : null,
              ),
              tooltip: 'Luôn hiển thị trên cùng',
              onPressed: () async {
                await _windowService.toggleAlwaysOnTop();
                setState(() {}); // Cập nhật UI
              },
            ),
            // Nút toàn màn hình
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: 'Toàn màn hình',
              onPressed: () async {
                await _windowService.toggleFullScreen();
              },
            ),
            if (_playlist != null)
              IconButton(
                icon: const Icon(Icons.skip_next),
                tooltip: 'Tiếp theo',
                onPressed: _hasNext ? _playNext : null,
              ),
          ],
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_currentMedia.name),
          actions: [
            // Nút Always on top
            IconButton(
              icon: Icon(
                Icons.pin_drop,
                color: _windowService.isAlwaysOnTop ? Colors.amber : null,
              ),
              tooltip: 'Luôn hiển thị trên cùng',
              onPressed: () async {
                await _windowService.toggleAlwaysOnTop();
                setState(() {}); // Cập nhật UI
              },
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _showControls
          ? AppBar(
              title: Text(_currentMedia.name),
              actions: [
                if (_playlist != null)
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    tooltip: 'Trước đó',
                    onPressed: _hasPrev ? _playPrev : null,
                  ),
                IconButton(
                  icon: const Icon(Icons.speed),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => PlaybackSpeedControl(
                        currentSpeed: _chewieController!.playbackSpeed,
                        onSpeedChanged: _setPlaybackSpeed,
                      ),
                    );
                  },
                ),
                if (_currentMedia.isVideo)
                  IconButton(
                    icon: const Icon(Icons.subtitles),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const SubtitleControl(),
                      );
                    },
                  ),
                if (_playlist != null)
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    tooltip: 'Tiếp theo',
                    onPressed: _hasNext ? _playNext : null,
                  ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTap: () {
          _skipForward(const Duration(seconds: 10));
        },
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            ),
            // Subtitle overlay
            if (_currentMedia.isVideo && _currentSubtitleText != null && _currentSubtitleText!.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Consumer<AppSettings>(
                  builder: (context, settings, _) => IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _currentSubtitleText!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: settings.subtitleColor,
                          fontSize: settings.subtitleFontSize,
                          fontFamily: settings.subtitleFontFamily,
                          backgroundColor: settings.subtitleBackgroundColor,
                          shadows: const [
                            Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(0.5, 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timeline with current time and duration
                      Row(
                        children: [
                          Text(
                            _formatDuration(_videoPlayerController!.value.position),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Expanded(
                            child: Slider(
                              value: _videoPlayerController!.value.duration > Duration.zero
                                  ? _videoPlayerController!.value.position.inMilliseconds /
                                      _videoPlayerController!.value.duration.inMilliseconds
                                  : 0.0,
                              onChanged: _seekToPosition,
                              activeColor: Colors.white,
                              inactiveColor: Colors.white24,
                            ),
                          ),
                          Text(
                            _formatDuration(_videoPlayerController!.value.duration),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Seek buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Backward buttons
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: () => _skipBackward(const Duration(minutes: 10)),
                                color: Colors.white,
                                iconSize: 32,
                                tooltip: 'Lùi 10 phút',
                              ),
                              const Text('10p', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_30),
                                onPressed: () => _skipBackward(const Duration(minutes: 1)),
                                color: Colors.white,
                                iconSize: 32,
                                tooltip: 'Lùi 1 phút',
                              ),
                              const Text('1p', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: () => _skipBackward(const Duration(seconds: 10)),
                                color: Colors.white,
                                iconSize: 32,
                                tooltip: 'Lùi 10 giây',
                              ),
                              const Text('10s', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 32),
                          // Play/Pause button
                          IconButton(
                            icon: Icon(
                              _videoPlayerController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: () {
                              if (_videoPlayerController!.value.isPlaying) {
                                _videoPlayerController!.pause();
                              } else {
                                _videoPlayerController!.play();
                              }
                              setState(() {});
                            },
                            color: Colors.white,
                            iconSize: 48,
                            tooltip: 'Phát/Tạm dừng',
                          ),
                          const SizedBox(width: 32),
                          // Forward buttons
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: () => _skipForward(const Duration(seconds: 10)),
                                color: Colors.white,
                                iconSize: 32,
                                tooltip: 'Tiến 10 giây',
                              ),
                              const Text('10s', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.forward_30),
                                onPressed: () => _skipForward(const Duration(minutes: 1)),
                                color: Colors.white,
                                iconSize: 32,
                                tooltip: 'Tiến 1 phút',
                              ),
                              const Text('1p', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: () => _skipForward(const Duration(minutes: 10)),
                                color: Colors.white,
                                iconSize: 32,
                                tooltip: 'Tiến 10 phút',
                              ),
                              const Text('10p', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Speed control row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _setPlaybackSpeed(
                              (_chewieController!.playbackSpeed - 0.25).clamp(0.1, 10.0)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('-0.25'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _setPlaybackSpeed(
                              (_chewieController!.playbackSpeed - 0.1).clamp(0.1, 10.0)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('-0.1'),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_chewieController!.playbackSpeed.toStringAsFixed(2)}x',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _setPlaybackSpeed(
                              (_chewieController!.playbackSpeed + 0.1).clamp(0.1, 10.0)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('+0.1'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _setPlaybackSpeed(
                              (_chewieController!.playbackSpeed + 0.25).clamp(0.1, 10.0)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('+0.25'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Preset speed buttons
                      PresetSpeedButtons(
                        currentSpeed: _chewieController!.playbackSpeed,
                        onSpeedChanged: _setPlaybackSpeed,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}