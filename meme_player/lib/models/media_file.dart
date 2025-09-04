class MediaFile {
  final String path;
  final String name;
  final String extension;
  final DateTime lastModified;
  final bool isVideo;
  String? subtitlePath;
  final Map<String, dynamic> metadata = {};

  MediaFile({
    required this.path,
    required this.name,
    required this.extension,
    required this.lastModified,
    required this.isVideo,
    this.subtitlePath,
  });

  bool get hasSubtitle => subtitlePath != null;

  // Check if the file is a supported video format
  static bool isSupportedVideoFormat(String extension) {
    final supportedFormats = [
      'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v'
    ];
    return supportedFormats.contains(extension.toLowerCase());
  }

  // Check if the file is a supported audio format
  static bool isSupportedAudioFormat(String extension) {
    final supportedFormats = [
      'mp3', 'wav', 'ogg', 'aac', 'm4a', 'flac', 'wma'
    ];
    return supportedFormats.contains(extension.toLowerCase());
  }

  // Factory method to create MediaFile from file path
  factory MediaFile.fromPath(String filePath) {
    final pathParts = filePath.split('\\');
    final fileName = pathParts.last;
    final nameParts = fileName.split('.');
    final extension = nameParts.last.toLowerCase();
    final name = nameParts.length > 1 
        ? fileName.substring(0, fileName.length - extension.length - 1) 
        : fileName;
    
    final isVideo = isSupportedVideoFormat(extension);
    
    // Check for subtitle file with same name
    final subtitlePath = filePath.substring(0, filePath.length - extension.length) + 'srt';
    
    return MediaFile(
      path: filePath,
      name: name,
      extension: extension,
      lastModified: DateTime.now(), // This would be replaced with actual file metadata
      isVideo: isVideo,
      subtitlePath: null, // This would be set if subtitle file exists
    );
  }
}