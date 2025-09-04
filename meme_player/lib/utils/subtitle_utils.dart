import 'dart:io';
import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';

class SubtitleUtils {
  /// Loads subtitles from a .srt file
  static Future<List<SubtitleEntry>?> loadSubtitlesFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return null;
      }
      
      final content = await file.readAsString();
      final subtitles = await SubtitleController().parseSubtitle(content);
      return subtitles;
    } catch (e) {
      debugPrint('Error loading subtitles: $e');
      return null;
    }
  }
  
  /// Finds a subtitle file with the same name as the video file
  static Future<String?> findSubtitleFile(String videoFilePath) async {
    final basePath = videoFilePath.substring(0, videoFilePath.lastIndexOf('.'));
    final srtPath = '$basePath.srt';
    
    final file = File(srtPath);
    if (await file.exists()) {
      return srtPath;
    }
    
    return null;
  }
  
  /// Gets the subtitle text for the current position
  static String? getSubtitleTextForPosition(
    List<SubtitleEntry> subtitles,
    Duration position,
    double playbackSpeed,
  ) {
    // Adjust position based on playback speed
    final adjustedPosition = Duration(
      milliseconds: (position.inMilliseconds / playbackSpeed).round(),
    );
    
    for (final subtitle in subtitles) {
      if (adjustedPosition >= subtitle.start && adjustedPosition <= subtitle.end) {
        return subtitle.text;
      }
    }
    
    return null;
  }
}

class SubtitleEntry {
  final int index;
  final Duration start;
  final Duration end;
  final String text;
  
  SubtitleEntry({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });
}