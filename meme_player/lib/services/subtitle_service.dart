import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:subtitle/subtitle.dart';
import '../utils/subtitle_utils.dart';
import 'package:subtitle/subtitle.dart' as sub;

class SubtitleService {
  // Singleton pattern
  static final SubtitleService _instance = SubtitleService._internal();
  factory SubtitleService() => _instance;
  SubtitleService._internal();

  // Lưu trữ các phụ đề đã tải
  final Map<String, List<sub.SubtitleEntry>> _loadedSubtitles = {};

  // Tải phụ đề từ tệp
  Future<List<sub.SubtitleEntry>?> loadSubtitleFromFile(String subtitlePath) async {
    if (_loadedSubtitles.containsKey(subtitlePath)) {
      return _loadedSubtitles[subtitlePath];
    }

    try {
      final subtitleFile = File(subtitlePath);
      if (!await subtitleFile.exists()) {
        debugPrint('Tệp phụ đề không tồn tại: $subtitlePath');
        return null;
      }

      final content = await subtitleFile.readAsString();
      final extension = path.extension(subtitlePath).toLowerCase();

      List<sub.SubtitleEntry> subtitles = [];
      if (extension == '.srt') {
        // Đã sửa lỗi: 'parseSrtSubtitle' bây giờ yêu cầu một provider
        subtitles = await sub.SubtitleConverter.convert(content);
      } else {
        debugPrint('Định dạng phụ đề không được hỗ trợ: $extension');
        return null;
      }

      _loadedSubtitles[subtitlePath] = subtitles;
      return subtitles;
    } catch (e) {
      debugPrint('Lỗi khi tải phụ đề: $e');
      return null;
    }
  }

  // Lấy phụ đề cho vị trí hiện tại
  String? getSubtitleTextAtPosition(String subtitlePath, Duration position, double playbackSpeed) {
    if (!_loadedSubtitles.containsKey(subtitlePath)) {
      return null;
    }

    // Điều chỉnh vị trí dựa trên tốc độ phát lại
    final adjustedPosition = Duration(milliseconds: (position.inMilliseconds / playbackSpeed).round());

    // Tìm phụ đề phù hợp với vị trí hiện tại
    for (final subtitle in _loadedSubtitles[subtitlePath]!) {
      if (subtitle.start <= adjustedPosition && adjustedPosition <= subtitle.end) {
        // Đã sửa lỗi: Thuộc tính 'data' đã được đổi tên thành 'text'
        return subtitle.text;
      }
    }

    return null;
  }

  // Xóa phụ đề đã tải
  void clearLoadedSubtitles() {
    _loadedSubtitles.clear();
  }

  // Xóa phụ đề cụ thể
  void removeSubtitle(String subtitlePath) {
    _loadedSubtitles.remove(subtitlePath);
  }
}
