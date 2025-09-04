import 'package:flutter/material.dart';
import '../models/plugin.dart';
import '../models/media_file.dart';
import '../services/subtitle_service.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class AutoSubtitlePlugin extends Plugin {
  AutoSubtitlePlugin()
      : super(
          id: 'auto_subtitle',
          name: 'Tự động tìm phụ đề',
          description: 'Tự động tìm và tải phụ đề cho video từ cùng thư mục',
          version: '1.0.0',
          author: 'Meme Player Team',
          icon: Icons.subtitles_outlined,
          type: PluginType.subtitle,
          priority: 1,
        );

  @override
  Future<void> onActivate() async {
    // Không cần làm gì khi kích hoạt
  }

  @override
  Future<void> onDeactivate() async {
    // Không cần làm gì khi vô hiệu hóa
  }

  @override
  Widget? configWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Plugin này sẽ tự động tìm kiếm tệp phụ đề có cùng tên với tệp video trong cùng thư mục.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        const Text(
          'Các định dạng phụ đề được hỗ trợ:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('.srt, .vtt, .sub, .ass, .ssa'),
      ],
    );
  }

  @override
  Future<MediaFile> processVideo(MediaFile mediaFile) async {
    if (!mediaFile.isVideo || !isEnabled) return mediaFile;

    final videoPath = mediaFile.path;
    final videoDir = path.dirname(videoPath);
    final videoName = path.basenameWithoutExtension(videoPath);

    // Các định dạng phụ đề phổ biến
    final subtitleExtensions = ['.srt', '.vtt', '.sub', '.ass', '.ssa'];

    // Tìm kiếm tệp phụ đề có cùng tên với video
    for (final ext in subtitleExtensions) {
      final subtitlePath = path.join(videoDir, '$videoName$ext');
      final subtitleFile = File(subtitlePath);

      if (await subtitleFile.exists()) {
        // Nếu tìm thấy, cập nhật đường dẫn phụ đề cho MediaFile
        mediaFile.subtitlePath = subtitlePath;
        
        // Tải phụ đề vào SubtitleService
        await SubtitleService().loadSubtitleFromFile(subtitlePath);
        
        break; // Dừng tìm kiếm khi đã tìm thấy phụ đề
      }
    }

    return mediaFile;
  }
}