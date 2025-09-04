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
          builder: (context) => PlayerScreen(mediaFile: mediaFile),
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
                          builder: (context) => PlayerScreen(mediaFile: file),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meme Player'),
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
          // Nút cài đặt
          Consumer<AppSettings>(
            builder: (context, settings, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                tooltip: 'Cài đặt',
                onSelected: (value) {
                  switch (value) {
                    case 'basic':
                      _showBasicSettings(context, settings);
                      break;
                    case 'advanced':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdvancedSettingsScreen(),
                        ),
                      );
                      break;
                    case 'plugins':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PluginsScreen(),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'basic',
                    child: Row(
                      children: [
                        Icon(Icons.tune),
                        SizedBox(width: 8),
                        Text('Cài đặt cơ bản'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'advanced',
                    child: Row(
                      children: [
                        Icon(Icons.settings_applications),
                        SizedBox(width: 8),
                        Text('Cài đặt nâng cao'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'plugins',
                    child: Row(
                      children: [
                        Icon(Icons.extension),
                        SizedBox(width: 8),
                        Text('Quản lý plugin'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Open file/folder buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_open),
                  label: const Text('Mở tệp'),
                  onPressed: _openFile,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Mở thư mục'),
                  onPressed: _openFolder,
                ),
              ],
            ),
          ),
          
          // Recent files
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recentFiles.isEmpty
                    ? const Center(
                        child: Text('Không có tệp nào được mở gần đây'),
                      )
                    : ListView.builder(
                        itemCount: _recentFiles.length,
                        itemBuilder: (context, index) {
                          final file = _recentFiles[index];
                          return ListTile(
                            leading: Icon(
                              file.isVideo ? Icons.video_file : Icons.audio_file,
                            ),
                            title: Text(file.name),
                            subtitle: Text(file.path),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(file.extension.toUpperCase()),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () async {
                                    // Xóa khỏi danh sách gần đây
                                    setState(() {
                                      _recentFiles.removeAt(index);
                                    });
                                    await _fileService.saveRecentFiles(_recentFiles);
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              // Kiểm tra xem tệp còn tồn tại không
                              final fileExists = await File(file.path).exists();
                              if (!fileExists) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tệp không tồn tại hoặc đã bị di chuyển')),
                                );
                                // Xóa khỏi danh sách gần đây
                                setState(() {
                                  _recentFiles.removeAt(index);
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
                                  builder: (context) => PlayerScreen(mediaFile: file),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}