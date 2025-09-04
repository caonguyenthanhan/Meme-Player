import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../services/plugin_service.dart';
import 'plugins_screen.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  final PluginService _pluginService = PluginService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt nâng cao'),
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Tùy chọn phát lại'),
              _buildPlaybackSettings(settings),
              
              _buildSectionHeader('Tùy chọn phụ đề'),
              _buildSubtitleSettings(settings),
              
              _buildSectionHeader('Tùy chọn giao diện'),
              _buildInterfaceSettings(settings),
              
              _buildSectionHeader('Quản lý plugin'),
              _buildPluginManagement(context),
              
              _buildSectionHeader('Thông tin ứng dụng'),
              _buildAppInfo(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  Widget _buildPlaybackSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Tự động phát'),
            subtitle: const Text('Tự động phát video khi mở'),
            value: settings.autoPlay,
            onChanged: (value) {
              settings.autoPlay = value;
            },
          ),
          SwitchListTile(
            title: const Text('Lặp lại'),
            subtitle: const Text('Tự động lặp lại video khi kết thúc'),
            value: settings.looping,
            onChanged: (value) {
              settings.looping = value;
            },
          ),
          ListTile(
            title: const Text('Tốc độ phát mặc định'),
            subtitle: Text('${settings.defaultPlaybackSpeed}x'),
            trailing: DropdownButton<double>(
              value: settings.defaultPlaybackSpeed,
              items: const [
                DropdownMenuItem(value: 0.25, child: Text('0.25x')),
                DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                DropdownMenuItem(value: 1.75, child: Text('1.75x')),
                DropdownMenuItem(value: 2.0, child: Text('2.0x')),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.defaultPlaybackSpeed = value;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubtitleSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Hiển thị phụ đề'),
            subtitle: const Text('Hiển thị phụ đề khi có sẵn'),
            value: settings.showSubtitles,
            onChanged: (value) {
              settings.showSubtitles = value;
            },
          ),
          ListTile(
            title: const Text('Kích thước phụ đề'),
            subtitle: Text('${settings.subtitleFontSize.toInt()}'),
            trailing: Slider(
              min: 12,
              max: 32,
              divisions: 10,
              label: settings.subtitleFontSize.toInt().toString(),
              value: settings.subtitleFontSize,
              onChanged: (value) {
                settings.subtitleFontSize = value;
              },
            ),
          ),
          ListTile(
            title: const Text('Màu phụ đề'),
            trailing: DropdownButton<String>(
              value: settings.subtitleColor,
              items: const [
                DropdownMenuItem(value: 'white', child: Text('Trắng')),
                DropdownMenuItem(value: 'yellow', child: Text('Vàng')),
                DropdownMenuItem(value: 'green', child: Text('Xanh lá')),
                DropdownMenuItem(value: 'cyan', child: Text('Xanh dương')),
                DropdownMenuItem(value: 'pink', child: Text('Hồng')),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.subtitleColor = value;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInterfaceSettings(AppSettings settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Chế độ tối'),
            subtitle: const Text('Sử dụng giao diện tối'),
            value: settings.darkMode,
            onChanged: (value) {
              settings.darkMode = value;
            },
          ),
          SwitchListTile(
            title: const Text('Hiển thị điều khiển'),
            subtitle: const Text('Luôn hiển thị thanh điều khiển'),
            value: settings.alwaysShowControls,
            onChanged: (value) {
              settings.alwaysShowControls = value;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPluginManagement(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text('Quản lý plugin'),
            subtitle: Text('${_pluginService.enabledPlugins.length} plugin đang hoạt động'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PluginsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppInfo() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Phiên bản'),
            subtitle: const Text('Meme Player v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Nhà phát triển'),
            subtitle: const Text('Meme Player Team'),
          ),
        ],
      ),
    );
  }
}