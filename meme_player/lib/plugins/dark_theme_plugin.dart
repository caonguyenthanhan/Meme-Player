import 'package:flutter/material.dart';
import '../models/plugin.dart';
import '../models/media_file.dart';
import '../models/app_settings.dart';
import 'package:provider/provider.dart';

class DarkThemePlugin extends Plugin {
  DarkThemePlugin()
      : super(
          id: 'dark_theme',
          name: 'Giao diện tối',
          description: 'Áp dụng giao diện tối cho toàn bộ ứng dụng',
          version: '1.0.0',
          author: 'Meme Player Team',
          icon: Icons.dark_mode,
          type: PluginType.ui,
          priority: 1,
        );

  @override
  Future<void> onActivate() async {
    // Khi kích hoạt plugin, bật chế độ tối trong AppSettings
  }

  @override
  Future<void> onDeactivate() async {
    // Khi vô hiệu hóa plugin, tắt chế độ tối trong AppSettings
  }

  @override
  Widget? configWidget(BuildContext context) {
    final appSettings = Provider.of<AppSettings>(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tùy chỉnh giao diện tối:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        
        // Tùy chọn tự động chuyển giao diện tối theo thời gian
        SwitchListTile(
          title: const Text('Tự động chuyển theo thời gian'),
          subtitle: const Text('Bật giao diện tối vào buổi tối (18:00 - 6:00)'),
          value: false, // Giá trị mặc định
          onChanged: (value) {
            // Trong thực tế, bạn sẽ lưu giá trị này và thiết lập một bộ hẹn giờ
            // để tự động chuyển đổi giao diện tối theo thời gian
          },
        ),
        
        // Tùy chọn độ tối của giao diện
        ListTile(
          title: const Text('Độ tối của giao diện'),
          subtitle: Slider(
            value: 0.7, // Giá trị mặc định
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: 'Độ tối: ${(0.7 * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              // Trong thực tế, bạn sẽ lưu giá trị này và áp dụng nó vào giao diện
            },
          ),
        ),
        
        // Nút áp dụng ngay
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Áp dụng chế độ tối ngay lập tức
              appSettings.darkMode = true;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã áp dụng giao diện tối')),
              );
            },
            child: const Text('Áp dụng ngay'),
          ),
        ),
      ],
    );
  }

  @override
  Future<MediaFile> processVideo(MediaFile mediaFile) async {
    // Plugin này không xử lý video, chỉ ảnh hưởng đến giao diện
    return mediaFile;
  }
}