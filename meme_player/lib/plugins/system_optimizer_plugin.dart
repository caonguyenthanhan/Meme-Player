import 'package:flutter/material.dart';
import '../models/plugin.dart';
import '../models/media_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SystemOptimizerPlugin extends Plugin {
  // Các tùy chọn tối ưu hóa hệ thống
  bool _clearCacheOnExit = true;
  bool _optimizeMemoryUsage = true;
  bool _optimizeStartup = true;
  int _maxCacheSize = 100; // MB

  SystemOptimizerPlugin()
      : super(
          id: 'system_optimizer',
          name: 'Tối ưu hóa hệ thống',
          description: 'Tự động tối ưu hóa bộ nhớ cache và hiệu suất ứng dụng',
          version: '1.0.0',
          author: 'Meme Player Team',
          icon: Icons.memory,
          type: PluginType.system,
          priority: 1,
        );

  // Getters cho các tùy chọn
  bool get clearCacheOnExit => _clearCacheOnExit;
  bool get optimizeMemoryUsage => _optimizeMemoryUsage;
  bool get optimizeStartup => _optimizeStartup;
  int get maxCacheSize => _maxCacheSize;

  // Setters cho các tùy chọn
  set clearCacheOnExit(bool value) {
    _clearCacheOnExit = value;
    notifyListeners();
  }

  set optimizeMemoryUsage(bool value) {
    _optimizeMemoryUsage = value;
    notifyListeners();
  }

  set optimizeStartup(bool value) {
    _optimizeStartup = value;
    notifyListeners();
  }

  set maxCacheSize(int value) {
    _maxCacheSize = value;
    notifyListeners();
  }

  @override
  Future<void> onActivate() async {
    // Khi kích hoạt plugin, thực hiện tối ưu hóa ban đầu
    if (_optimizeStartup) {
      await _optimizeSystem();
    }
  }

  @override
  Future<void> onDeactivate() async {
    // Khi vô hiệu hóa plugin, xóa cache nếu được cấu hình
    if (_clearCacheOnExit) {
      await _clearCache();
    }
  }

  Future<void> _optimizeSystem() async {
    // Mô phỏng việc tối ưu hóa hệ thống
    debugPrint('Đang tối ưu hóa hệ thống...');
    
    // Kiểm tra và xóa cache nếu vượt quá kích thước tối đa
    await _manageCacheSize();
    
    debugPrint('Đã hoàn thành tối ưu hóa hệ thống');
  }

  Future<void> _clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
        debugPrint('Đã xóa cache thành công');
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa cache: $e');
    }
  }

  Future<void> _manageCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        final cacheSize = await _calculateDirectorySize(cacheDir);
        final cacheSizeMB = cacheSize / (1024 * 1024); // Chuyển đổi sang MB
        
        if (cacheSizeMB > _maxCacheSize) {
          debugPrint('Kích thước cache ($cacheSizeMB MB) vượt quá giới hạn ($_maxCacheSize MB). Đang xóa cache...');
          await _clearCache();
        } else {
          debugPrint('Kích thước cache hiện tại: $cacheSizeMB MB (giới hạn: $_maxCacheSize MB)');
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi quản lý kích thước cache: $e');
    }
  }

  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      final List<FileSystemEntity> entities = await directory.list(recursive: true).toList();
      for (final entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi tính kích thước thư mục: $e');
    }
    return totalSize;
  }

  @override
  Widget? configWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tùy chỉnh tối ưu hóa hệ thống:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        
        // Tùy chọn xóa cache khi thoát
        SwitchListTile(
          title: const Text('Xóa cache khi thoát'),
          subtitle: const Text('Tự động xóa bộ nhớ cache khi thoát ứng dụng'),
          value: _clearCacheOnExit,
          onChanged: (value) {
            clearCacheOnExit = value;
          },
        ),
        
        // Tùy chọn tối ưu hóa bộ nhớ
        SwitchListTile(
          title: const Text('Tối ưu hóa bộ nhớ'),
          subtitle: const Text('Tự động giải phóng bộ nhớ không sử dụng'),
          value: _optimizeMemoryUsage,
          onChanged: (value) {
            optimizeMemoryUsage = value;
          },
        ),
        
        // Tùy chọn tối ưu hóa khi khởi động
        SwitchListTile(
          title: const Text('Tối ưu hóa khi khởi động'),
          subtitle: const Text('Tự động tối ưu hóa hệ thống khi khởi động ứng dụng'),
          value: _optimizeStartup,
          onChanged: (value) {
            optimizeStartup = value;
          },
        ),
        
        // Tùy chọn kích thước cache tối đa
        ListTile(
          title: const Text('Kích thước cache tối đa (MB)'),
          subtitle: Slider(
            value: _maxCacheSize.toDouble(),
            min: 50,
            max: 500,
            divisions: 9,
            label: '$_maxCacheSize MB',
            onChanged: (value) {
              maxCacheSize = value.toInt();
            },
          ),
        ),
        
        // Nút xóa cache ngay
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await _clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa cache thành công')),
                );
              }
            },
            child: const Text('Xóa cache ngay'),
          ),
        ),
      ],
    );
  }

  @override
  Future<MediaFile> processVideo(MediaFile mediaFile) async {
    // Plugin này không xử lý video, chỉ tối ưu hóa hệ thống
    return mediaFile;
  }
}