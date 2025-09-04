import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  // Singleton pattern
  static final WindowService _instance = WindowService._internal();
  factory WindowService() => _instance;
  WindowService._internal();

  bool _isInitialized = false;
  bool _isAlwaysOnTop = false;

  // Getter cho trạng thái always-on-top
  bool get isAlwaysOnTop => _isAlwaysOnTop;

  // Khởi tạo window manager
  Future<void> initializeWindow() async {
    // Chỉ áp dụng cho desktop platforms
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      await windowManager.ensureInitialized();
      
      const WindowOptions windowOptions = WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: null,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      
      _isInitialized = true;
    }
  }

  // Bật/tắt chế độ always-on-top
  Future<void> toggleAlwaysOnTop() async {
    if (!_isInitialized) {
      debugPrint('Window manager not initialized');
      return;
    }
    
    _isAlwaysOnTop = !_isAlwaysOnTop;
    await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
    debugPrint('Always on top: $_isAlwaysOnTop');
  }

  // Đặt chế độ always-on-top
  Future<void> setAlwaysOnTop(bool value) async {
    if (!_isInitialized) {
      debugPrint('Window manager not initialized');
      return;
    }
    
    if (_isAlwaysOnTop != value) {
      _isAlwaysOnTop = value;
      await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
      debugPrint('Always on top set to: $_isAlwaysOnTop');
    }
  }

  // Thay đổi kích thước cửa sổ
  Future<void> resizeWindow(Size size) async {
    if (!_isInitialized) {
      debugPrint('Window manager not initialized');
      return;
    }
    
    await windowManager.setSize(size);
  }

  // Chuyển đổi chế độ toàn màn hình
  Future<void> toggleFullScreen() async {
    if (!_isInitialized) {
      debugPrint('Window manager not initialized');
      return;
    }
    
    final isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }
}