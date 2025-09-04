import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_file.dart';
import '../utils/subtitle_utils.dart';

class FileService {
  static const String _recentFilesKey = 'recent_files';
  static const int _maxRecentFiles = 10;

  // Lấy danh sách các tệp media từ một thư mục
  Future<List<MediaFile>> getMediaFilesFromDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return [];
    }

    final List<MediaFile> mediaFiles = [];
    final List<FileSystemEntity> entities = directory.listSync();

    for (final entity in entities) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase().replaceAll('.', '');
        if (MediaFile.isSupportedVideoFormat(extension) || 
            MediaFile.isSupportedAudioFormat(extension)) {
          final mediaFile = await _createMediaFileWithSubtitle(entity.path);
          mediaFiles.add(mediaFile);
        }
      }
    }

    return mediaFiles;
  }

  // Tạo MediaFile với thông tin phụ đề (nếu có)
  Future<MediaFile> _createMediaFileWithSubtitle(String filePath) async {
    final pathParts = filePath.split('\\');
    final fileName = pathParts.last;
    final nameParts = fileName.split('.');
    final extension = nameParts.last.toLowerCase();
    final name = nameParts.length > 1 
        ? fileName.substring(0, fileName.length - extension.length - 1) 
        : fileName;
    
    final isVideo = MediaFile.isSupportedVideoFormat(extension);
    
    // Kiểm tra file phụ đề
    String? subtitlePath;
    if (isVideo) {
      subtitlePath = await SubtitleUtils.findSubtitleFile(filePath);
    }
    
    final file = File(filePath);
    final lastModified = await file.lastModified();
    
    return MediaFile(
      path: filePath,
      name: name,
      extension: extension,
      lastModified: lastModified,
      isVideo: isVideo,
      subtitlePath: subtitlePath,
    );
  }

  // Lưu danh sách tệp gần đây
  Future<void> saveRecentFiles(List<MediaFile> files) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> filePaths = files.map((file) => file.path).toList();
    await prefs.setStringList(_recentFilesKey, filePaths);
  }

  // Lấy danh sách tệp gần đây
  Future<List<MediaFile>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> filePaths = prefs.getStringList(_recentFilesKey) ?? [];
    
    final List<MediaFile> mediaFiles = [];
    for (final path in filePaths) {
      final file = File(path);
      if (file.existsSync()) {
        final mediaFile = await _createMediaFileWithSubtitle(path);
        mediaFiles.add(mediaFile);
      }
    }
    
    return mediaFiles;
  }

  // Thêm tệp vào danh sách gần đây
  Future<void> addToRecentFiles(MediaFile file) async {
    final recentFiles = await getRecentFiles();
    
    // Xóa nếu đã tồn tại
    recentFiles.removeWhere((item) => item.path == file.path);
    
    // Thêm vào đầu danh sách
    recentFiles.insert(0, file);
    
    // Giới hạn số lượng
    if (recentFiles.length > _maxRecentFiles) {
      recentFiles.removeLast();
    }
    
    await saveRecentFiles(recentFiles);
  }
}