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

class PlayerScreen extends StatefulWidget {
  final MediaFile mediaFile;

  const PlayerScreen({super.key, required this.mediaFile});

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

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final file = File(widget.mediaFile.path);
      if (!file.existsSync()) {
        setState(() {
          _errorMessage = 'Tệp không tồn tại: ${widget.mediaFile.path}';
        });
        return;
      }

      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();

      // Get playback speed from settings
      final settings = Provider.of<AppSettings>(context, listen: false);
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        playbackSpeeds: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
        playbackSpeed: settings.playbackSpeed,
        subtitle: widget.mediaFile.hasSubtitle
            ? Subtitles([
                Subtitle(
                  index: 0,
                  start: Duration.zero,
                  end: const Duration(seconds: 3),
                  text: 'Phụ đề mẫu (sẽ được thay thế bằng phụ đề thực tế)',
                ),
              ])
            : null,
        subtitleBuilder: (context, subtitle) => Container(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            subtitle,
            style: TextStyle(
              color: settings.subtitleColor,
              fontSize: settings.subtitleFontSize,
              fontFamily: settings.subtitleFontFamily,
              backgroundColor: settings.subtitleBackgroundColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );

      setState(() {
        _isInitialized = true;
      });
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

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.mediaFile.name),
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
            // Nút toàn màn hình
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: 'Toàn màn hình',
              onPressed: () async {
                await _windowService.toggleFullScreen();
              },
            ),
          ],
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.mediaFile.name),
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
              title: Text(widget.mediaFile.name),
              actions: [
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
                if (widget.mediaFile.isVideo)
                  IconButton(
                    icon: const Icon(Icons.subtitles),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const SubtitleControl(),
                      );
                    },
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
            if (_showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () => _skipBackward(const Duration(seconds: 10)),
                      color: Colors.white,
                      iconSize: 36,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.replay_30),
                      onPressed: () => _skipBackward(const Duration(seconds: 30)),
                      color: Colors.white,
                      iconSize: 36,
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      icon: const Icon(Icons.forward_30),
                      onPressed: () => _skipForward(const Duration(seconds: 30)),
                      color: Colors.white,
                      iconSize: 36,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () => _skipForward(const Duration(seconds: 10)),
                      color: Colors.white,
                      iconSize: 36,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}