import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plugin.dart';
import '../services/plugin_service.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PluginService _pluginService = PluginService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: PluginType.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Plugin'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: PluginType.values.map((type) => _buildTabLabel(type)).toList(),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: _pluginService,
        child: TabBarView(
          controller: _tabController,
          children: PluginType.values.map((type) => _buildPluginList(type)).toList(),
        ),
      ),
    );
  }

  Widget _buildTabLabel(PluginType type) {
    IconData icon;
    String label;

    switch (type) {
      case PluginType.video:
        icon = Icons.videocam;
        label = 'Video';
        break;
      case PluginType.audio:
        icon = Icons.audiotrack;
        label = 'Âm thanh';
        break;
      case PluginType.subtitle:
        icon = Icons.subtitles;
        label = 'Phụ đề';
        break;
      case PluginType.ui:
        icon = Icons.palette;
        label = 'Giao diện';
        break;
      case PluginType.system:
        icon = Icons.settings;
        label = 'Hệ thống';
        break;
    }

    return Tab(
      icon: Icon(icon),
      text: label,
    );
  }

  Widget _buildPluginList(PluginType type) {
    return Consumer<PluginService>(
      builder: (context, pluginService, child) {
        final plugins = pluginService.getPluginsByType(type);

        if (plugins.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.extension_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Không có plugin ${_getPluginTypeText(type)}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: plugins.length,
          itemBuilder: (context, index) {
            final plugin = plugins[index];
            return _buildPluginCard(plugin, pluginService);
          },
        );
      },
    );
  }

  String _getPluginTypeText(PluginType type) {
    switch (type) {
      case PluginType.video:
        return 'video';
      case PluginType.audio:
        return 'âm thanh';
      case PluginType.subtitle:
        return 'phụ đề';
      case PluginType.ui:
        return 'giao diện';
      case PluginType.system:
        return 'hệ thống';
    }
  }

  Widget _buildPluginCard(Plugin plugin, PluginService pluginService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(plugin.icon, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Phiên bản: ${plugin.version} | Tác giả: ${plugin.author}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: plugin.isEnabled,
                  onChanged: (value) {
                    pluginService.togglePlugin(plugin.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(plugin.description),
            const SizedBox(height: 8),
            if (plugin.configWidget != null && plugin.isEnabled)
              ElevatedButton(
                onPressed: () {
                  _showPluginConfig(context, plugin);
                },
                child: const Text('Cấu hình'),
              ),
          ],
        ),
      ),
    );
  }

  void _showPluginConfig(BuildContext context, Plugin plugin) {
    if (plugin.configWidget == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cấu hình ${plugin.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: plugin.configWidget!(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}