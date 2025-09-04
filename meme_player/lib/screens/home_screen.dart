import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/media_file.dart';
import '../models/app_settings.dart';
import '../services/file_service.dart';
import '../services/window_service.dart';
import '../services/plugin_service.dart';
import 'player_screen.dart';
import 'advanced_settings_screen.dart';
import 'plugins_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MediaFile> _recentFiles = [];
  final FileService _fileService = FileService();
  final WindowService _windowService = WindowService();
  final PluginService _pluginService = PluginService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load recent files from storage
    _loadRecentFiles();
    // Load default plugins
    _pluginService.loadDefaultPlugins();
    _pluginService.loadPluginsState();
  }

  Future<void> _loadRecentFiles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final recentFiles = await _fileService.getRecentFiles();
      setState(() {
        _recentFiles.clear();
        _recentFiles.addAll(recentFiles);
      });
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách tệp gần đây: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v',
        'mp3', 'wav', 'ogg', 'aac', 'm4a', 'flac', 'wma'
      ],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final mediaFile = await _fileService._createMediaFileWithSubtitle(filePath);
      
      // Add to recent files
      await _fileService.addToRecentFiles(mediaFile);
      
      // Refresh recent files list
      await _loadRecentFiles();
      
      // Navigate to player screen
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            mediaFile: mediaFile,
            playlist: null,
            initialIndex: 0,
          ),
        ),
      );
    }
  }

  Future<void> _openFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Quét thư mục để tìm các tệp media
        final mediaFiles = await _fileService.getMediaFilesFromDirectory(selectedDirectory);
        
        if (mediaFiles.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy tệp media nào trong thư mục này')),
          );
          return;
        }
        
        if (!mounted) return;
        // Hiển thị dialog để chọn tệp
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Tìm thấy ${mediaFiles.length} tệp media'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: mediaFiles.length,
                itemBuilder: (context, index) {
                  final file = mediaFiles[index];
                  return ListTile(
                    leading: Icon(
                      file.isVideo ? Icons.video_file : Icons.audio_file,
                    ),
                    title: Text(file.name),
                    subtitle: Text(file.extension.toUpperCase()),
                    onTap: () async {
                      // Thêm vào danh sách gần đây
                      await _fileService.addToRecentFiles(file);
                      await _loadRecentFiles();
                      
                      if (!mounted) return;
                      Navigator.pop(context); // Đóng dialog
                      
                      // Mở tệp
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(
                            mediaFile: file,
                            playlist: mediaFiles,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi quét thư mục: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showBasicSettings(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt cơ bản'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chế độ tối
              SwitchListTile(
                title: const Text('Chế độ tối'),
                value: settings.darkMode,
                onChanged: (value) {
                  settings.darkMode = value;
                },
              ),
              // Tốc độ phát mặc định
              ListTile(
                title: const Text('Tốc độ phát mặc định'),
                subtitle: Slider(
                  min: 0.25,
                  max: 2.0,
                  divisions: 7,
                  value: settings.defaultPlaybackSpeed,
                  label: '${settings.defaultPlaybackSpeed}x',
                  onChanged: (value) {
                    settings.defaultPlaybackSpeed = value;
                  },
                ),
              ),
              // Hiển thị phụ đề
              SwitchListTile(
                title: const Text('Hiển thị phụ đề'),
                value: settings.showSubtitles,
                onChanged: (value) {
                  settings.showSubtitles = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSettingsScreen(),
                ),
              );
            },
            child: const Text('Cài đặt nâng cao'),
          ),
        ],
      ),
    );
  }

  void _openRecentFile(MediaFile file) async {
    // Kiểm tra xem tệp còn tồn tại không
    final fileExists = await File(file.path).exists();
    if (!fileExists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tệp không tồn tại hoặc đã bị di chuyển')),
      );
      // Xóa khỏi danh sách gần đây
      setState(() {
        _recentFiles.remove(file);
      });
      await _fileService.saveRecentFiles(_recentFiles);
      return;
    }
    
    // Cập nhật thứ tự trong danh sách gần đây
    await _fileService.addToRecentFiles(file);
    await _loadRecentFiles();
    
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          mediaFile: file,
          playlist: _recentFiles,
          initialIndex: _recentFiles.indexOf(file),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meme Player',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSettingsScreen(),
                ),
              );
            },
            tooltip: 'Cài đặt',
          ),
          IconButton(
            icon: const Icon(Icons.extension),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PluginsScreen(),
                ),
              );
            },
            tooltip: 'Plugins',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chào mừng đến với Meme Player',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ứng dụng phát media đa năng với nhiều tính năng nâng cao',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openFile,
                      icon: const Icon(Icons.file_open),
                      label: const Text(
                        'Mở file',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openFolder,
                      icon: const Icon(Icons.folder_open),
                      label: const Text(
                        'Mở thư mục',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Recent files section
              if (_recentFiles.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tệp gần đây',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _loadRecentFiles,
                      child: const Text('Làm mới'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _recentFiles.length,
                            itemBuilder: (context, index) {
                              final file = _recentFiles[index];
                              return ListTile(
                                leading: Icon(
                                  file.isVideo ? Icons.video_file : Icons.audio_file,
                                  color: file.isVideo
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                                title: Text(
                                  file.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  file.path,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  onPressed: () => _openRecentFile(file),
                                ),
                                onTap: () => _openRecentFile(file),
                              );
                            },
                          ),
                  ),
                ),
              ] else ...[
                // Empty state
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có tệp nào được mở',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy mở file hoặc thư mục để bắt đầu',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}