import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plugin.dart';
import '../models/media_file.dart';
import '../plugins/auto_subtitle_plugin.dart';
import '../plugins/video_enhancer_plugin.dart';
import '../plugins/audio_enhancer_plugin.dart';
import '../plugins/dark_theme_plugin.dart';
import '../plugins/system_optimizer_plugin.dart';

class PluginService extends ChangeNotifier {
  // Singleton pattern
  static final PluginService _instance = PluginService._internal();
  factory PluginService() => _instance;
  PluginService._internal();

  // Danh sách các plugin đã cài đặt
  final List<Plugin> _plugins = [];
  
  // Key lưu trữ trạng thái plugin trong SharedPreferences
  static const String _pluginsStateKey = 'plugins_state';

  // Getter cho danh sách plugin
  List<Plugin> get plugins => List.unmodifiable(_plugins);
  
  // Getter cho danh sách plugin đã kích hoạt
  List<Plugin> get enabledPlugins => _plugins.where((plugin) => plugin.isEnabled).toList();
  
  // Getter cho danh sách plugin theo loại
  List<Plugin> getPluginsByType(PluginType type) {
    return _plugins.where((plugin) => plugin.type == type).toList();
  }
  
  // Getter cho danh sách plugin đã kích hoạt theo loại
  List<Plugin> getEnabledPluginsByType(PluginType type) {
    return _plugins.where((plugin) => plugin.type == type && plugin.isEnabled).toList();
  }

  // Đăng ký một plugin mới
  void registerPlugin(Plugin plugin) {
    // Kiểm tra xem plugin đã tồn tại chưa
    final existingIndex = _plugins.indexWhere((p) => p.id == plugin.id);
    
    if (existingIndex >= 0) {
      // Cập nhật plugin hiện có
      _plugins[existingIndex] = plugin;
    } else {
      // Thêm plugin mới
      _plugins.add(plugin);
    }
    
    // Sắp xếp lại danh sách plugin theo thứ tự ưu tiên
    _plugins.sort((a, b) => a.priority.compareTo(b.priority));
    
    // Thông báo thay đổi
    notifyListeners();
    
    // Lưu trạng thái
    _savePluginsState();
  }

  // Gỡ bỏ một plugin
  void unregisterPlugin(String pluginId) {
    final index = _plugins.indexWhere((p) => p.id == pluginId);
    
    if (index >= 0) {
      // Vô hiệu hóa plugin trước khi gỡ bỏ
      if (_plugins[index].isEnabled) {
        _plugins[index].deactivate();
      }
      
      // Gỡ bỏ plugin
      _plugins.removeAt(index);
      
      // Thông báo thay đổi
      notifyListeners();
      
      // Lưu trạng thái
      _savePluginsState();
    }
  }

  // Kích hoạt một plugin
  void activatePlugin(String pluginId) {
    final index = _plugins.indexWhere((p) => p.id == pluginId);
    
    if (index >= 0 && !_plugins[index].isEnabled) {
      _plugins[index].activate();
      
      // Thông báo thay đổi
      notifyListeners();
      
      // Lưu trạng thái
      _savePluginsState();
    }
  }

  // Vô hiệu hóa một plugin
  void deactivatePlugin(String pluginId) {
    final index = _plugins.indexWhere((p) => p.id == pluginId);
    
    if (index >= 0 && _plugins[index].isEnabled) {
      _plugins[index].deactivate();
      
      // Thông báo thay đổi
      notifyListeners();
      
      // Lưu trạng thái
      _savePluginsState();
    }
  }

  // Chuyển đổi trạng thái kích hoạt của plugin
  void togglePlugin(String pluginId) {
    final index = _plugins.indexWhere((p) => p.id == pluginId);
    
    if (index >= 0) {
      _plugins[index].toggle();
      
      // Thông báo thay đổi
      notifyListeners();
      
      // Lưu trạng thái
      _savePluginsState();
    }
  }

  // Lưu trạng thái của các plugin
  Future<void> _savePluginsState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Tạo danh sách các plugin với trạng thái kích hoạt
      final List<Map<String, dynamic>> pluginsState = _plugins.map((plugin) => {
        'id': plugin.id,
        'isEnabled': plugin.isEnabled,
      }).toList();
      
      // Lưu vào SharedPreferences
      await prefs.setString(_pluginsStateKey, jsonEncode(pluginsState));
    } catch (e) {
      debugPrint('Lỗi khi lưu trạng thái plugin: $e');
    }
  }

  // Tải trạng thái của các plugin
  Future<void> loadPluginsState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? pluginsStateJson = prefs.getString(_pluginsStateKey);
      
      if (pluginsStateJson != null) {
        final List<dynamic> pluginsState = jsonDecode(pluginsStateJson);
        
        // Cập nhật trạng thái cho các plugin
        for (final state in pluginsState) {
          final String id = state['id'];
          final bool isEnabled = state['isEnabled'];
          
          final index = _plugins.indexWhere((p) => p.id == id);
          if (index >= 0) {
            if (isEnabled) {
              _plugins[index].activate();
            } else {
              _plugins[index].deactivate();
            }
          }
        }
        
        // Thông báo thay đổi
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi khi tải trạng thái plugin: $e');
    }
  }

  // Xử lý video với các plugin đã kích hoạt
  MediaFile processVideo(MediaFile mediaFile) {
    // Lấy danh sách các plugin video đã kích hoạt
    final videoPlugins = getEnabledPluginsByType(PluginType.video);
    
    // Không có plugin nào được kích hoạt
    if (videoPlugins.isEmpty) {
      return mediaFile;
    }
    
    // Xử lý video với từng plugin theo thứ tự ưu tiên
    MediaFile processedFile = mediaFile;
    for (final plugin in videoPlugins) {
      // Giả định rằng mỗi plugin có một hàm processVideo
      // Trong thực tế, bạn cần định nghĩa một interface cho các plugin video
      if (plugin.onActivate != null) {
        try {
          // Đây chỉ là mô phỏng, trong thực tế bạn cần một cách tốt hơn để xử lý video
          // processedFile = plugin.processVideo(processedFile);
        } catch (e) {
          debugPrint('Lỗi khi xử lý video với plugin ${plugin.name}: $e');
        }
      }
    }
    
    return processedFile;
  }

  // Tải các plugin mặc định của ứng dụng
  Future<void> loadDefaultPlugins() async {
    // Đăng ký các plugin mẫu
    // Lưu ý: Các lớp plugin đã được import ở đầu tệp
    registerPlugin(AutoSubtitlePlugin());
    registerPlugin(VideoEnhancerPlugin());
    registerPlugin(AudioEnhancerPlugin());
    registerPlugin(DarkThemePlugin());
    registerPlugin(SystemOptimizerPlugin());

    // Tải trạng thái plugin từ bộ nhớ
    await loadPluginsState();
  }
}