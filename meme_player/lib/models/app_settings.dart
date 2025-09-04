import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  // Giao diện
  bool _darkMode = false;
  bool _alwaysOnTop = false;
  bool _alwaysShowControls = false;
  
  // Phát lại
  double _playbackSpeed = 1.0;
  double _defaultPlaybackSpeed = 1.0;
  bool _autoPlay = true;
  bool _looping = true;
  
  // Phụ đề
  bool _showSubtitles = true;
  String _subtitleFontFamily = 'Arial';
  double _subtitleFontSize = 16.0;
  Color _subtitleColor = Colors.white;
  Color _subtitleBackgroundColor = Colors.black.withOpacity(0.5);

  // Getters - Giao diện
  bool get darkMode => _darkMode;
  bool get alwaysOnTop => _alwaysOnTop;
  bool get alwaysShowControls => _alwaysShowControls;
  
  // Getters - Phát lại
  double get playbackSpeed => _playbackSpeed;
  double get defaultPlaybackSpeed => _defaultPlaybackSpeed;
  bool get autoPlay => _autoPlay;
  bool get looping => _looping;
  
  // Getters - Phụ đề
  bool get showSubtitles => _showSubtitles;
  String get subtitleFontFamily => _subtitleFontFamily;
  double get subtitleFontSize => _subtitleFontSize;
  Color get subtitleColor => _subtitleColor;
  Color get subtitleBackgroundColor => _subtitleBackgroundColor;

  AppSettings() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Giao diện
    _darkMode = prefs.getBool('darkMode') ?? false;
    _alwaysOnTop = prefs.getBool('alwaysOnTop') ?? false;
    _alwaysShowControls = prefs.getBool('alwaysShowControls') ?? false;
    
    // Phát lại
    _playbackSpeed = prefs.getDouble('playbackSpeed') ?? 1.0;
    _defaultPlaybackSpeed = prefs.getDouble('defaultPlaybackSpeed') ?? 1.0;
    _autoPlay = prefs.getBool('autoPlay') ?? true;
    _looping = prefs.getBool('looping') ?? true;
    
    // Phụ đề
    _showSubtitles = prefs.getBool('showSubtitles') ?? true;
    _subtitleFontFamily = prefs.getString('subtitleFontFamily') ?? 'Arial';
    _subtitleFontSize = prefs.getDouble('subtitleFontSize') ?? 16.0;
    _subtitleColor = Color(prefs.getInt('subtitleColor') ?? Colors.white.value);
    _subtitleBackgroundColor = Color(prefs.getInt('subtitleBackgroundColor') ?? 
        Colors.black.withOpacity(0.5).value);
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Giao diện
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('alwaysOnTop', _alwaysOnTop);
    await prefs.setBool('alwaysShowControls', _alwaysShowControls);
    
    // Phát lại
    await prefs.setDouble('playbackSpeed', _playbackSpeed);
    await prefs.setDouble('defaultPlaybackSpeed', _defaultPlaybackSpeed);
    await prefs.setBool('autoPlay', _autoPlay);
    await prefs.setBool('looping', _looping);
    
    // Phụ đề
    await prefs.setBool('showSubtitles', _showSubtitles);
    await prefs.setString('subtitleFontFamily', _subtitleFontFamily);
    await prefs.setDouble('subtitleFontSize', _subtitleFontSize);
    await prefs.setInt('subtitleColor', _subtitleColor.value);
    await prefs.setInt('subtitleBackgroundColor', _subtitleBackgroundColor.value);
  }

  // Setters - Giao diện
  set darkMode(bool value) {
    _darkMode = value;
    _saveSettings();
    notifyListeners();
  }

  set alwaysOnTop(bool value) {
    _alwaysOnTop = value;
    _saveSettings();
    notifyListeners();
  }
  
  set alwaysShowControls(bool value) {
    _alwaysShowControls = value;
    _saveSettings();
    notifyListeners();
  }
  
  // Setters - Phát lại
  set playbackSpeed(double value) {
    _playbackSpeed = value;
    _saveSettings();
    notifyListeners();
  }
  
  set defaultPlaybackSpeed(double value) {
    _defaultPlaybackSpeed = value;
    _saveSettings();
    notifyListeners();
  }
  
  set autoPlay(bool value) {
    _autoPlay = value;
    _saveSettings();
    notifyListeners();
  }
  
  set looping(bool value) {
    _looping = value;
    _saveSettings();
    notifyListeners();
  }
  
  // Setters - Phụ đề
  set showSubtitles(bool value) {
    _showSubtitles = value;
    _saveSettings();
    notifyListeners();
  }

  set subtitleFontFamily(String value) {
    _subtitleFontFamily = value;
    _saveSettings();
    notifyListeners();
  }

  set subtitleFontSize(double value) {
    _subtitleFontSize = value;
    _saveSettings();
    notifyListeners();
  }

  set subtitleColor(Color value) {
    _subtitleColor = value;
    _saveSettings();
    notifyListeners();
  }

  set subtitleBackgroundColor(Color value) {
    _subtitleBackgroundColor = value;
    _saveSettings();
    notifyListeners();
  }
}