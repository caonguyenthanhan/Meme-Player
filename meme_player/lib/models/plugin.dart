import 'package:flutter/material.dart';

/// Định nghĩa một plugin cho Meme Player
class Plugin {
  /// ID duy nhất của plugin
  final String id;
  
  /// Tên hiển thị của plugin
  final String name;
  
  /// Mô tả về chức năng của plugin
  final String description;
  
  /// Phiên bản của plugin
  final String version;
  
  /// Tác giả của plugin
  final String author;
  
  /// Icon hiển thị cho plugin
  final IconData icon;
  
  /// Trạng thái kích hoạt của plugin
  bool isEnabled;
  
  /// Thứ tự ưu tiên của plugin (số càng nhỏ càng ưu tiên cao)
  final int priority;
  
  /// Loại plugin (video, audio, subtitle, ui, system)
  final PluginType type;
  
  /// Hàm xử lý khi plugin được kích hoạt
  final Function? onActivate;
  
  /// Hàm xử lý khi plugin bị vô hiệu hóa
  final Function? onDeactivate;
  
  /// Widget cấu hình cho plugin (nếu có)
  final Widget Function(BuildContext)? configWidget;
  
  Plugin({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.author,
    required this.icon,
    required this.type,
    this.isEnabled = false,
    this.priority = 100,
    this.onActivate,
    this.onDeactivate,
    this.configWidget,
  });
  
  /// Kích hoạt plugin
  void activate() {
    isEnabled = true;
    if (onActivate != null) {
      onActivate!();
    }
  }
  
  /// Vô hiệu hóa plugin
  void deactivate() {
    isEnabled = false;
    if (onDeactivate != null) {
      onDeactivate!();
    }
  }
  
  /// Chuyển đổi trạng thái kích hoạt của plugin
  void toggle() {
    if (isEnabled) {
      deactivate();
    } else {
      activate();
    }
  }
  
  /// Tạo một bản sao của plugin với các thuộc tính được cập nhật
  Plugin copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    String? author,
    IconData? icon,
    bool? isEnabled,
    int? priority,
    PluginType? type,
    Function? onActivate,
    Function? onDeactivate,
    Widget Function(BuildContext)? configWidget,
  }) {
    return Plugin(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      author: author ?? this.author,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      onActivate: onActivate ?? this.onActivate,
      onDeactivate: onDeactivate ?? this.onDeactivate,
      configWidget: configWidget ?? this.configWidget,
    );
  }
}

/// Các loại plugin được hỗ trợ
enum PluginType {
  /// Plugin xử lý video
  video,
  
  /// Plugin xử lý audio
  audio,
  
  /// Plugin xử lý phụ đề
  subtitle,
  
  /// Plugin tùy chỉnh giao diện
  ui,
  
  /// Plugin hệ thống
  system,
}