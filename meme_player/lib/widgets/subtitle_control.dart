import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';

class SubtitleControl extends StatelessWidget {
  const SubtitleControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tùy chỉnh phụ đề',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Font size
              Row(
                children: [
                  const Text('Kích thước chữ:'),
                  Expanded(
                    child: Slider(
                      value: settings.subtitleFontSize,
                      min: 8.0,
                      max: 32.0,
                      divisions: 24,
                      label: '${settings.subtitleFontSize.toStringAsFixed(1)}',
                      onChanged: (value) {
                        settings.setSubtitleFontSize(value);
                      },
                    ),
                  ),
                  Text('${settings.subtitleFontSize.toStringAsFixed(1)}'),
                ],
              ),
              
              // Font color
              ListTile(
                title: const Text('Màu chữ'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  color: settings.subtitleColor,
                ),
                onTap: () {
                  _showColorPicker(
                    context,
                    settings.subtitleColor,
                    (color) => settings.subtitleColor = color,
                  );
                },
              ),
              
              // Background color
              ListTile(
                title: const Text('Màu nền'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  color: settings.subtitleBackgroundColor,
                ),
                onTap: () {
                  _showColorPicker(
                    context,
                    settings.subtitleBackgroundColor,
                    (color) => settings.setSubtitleBackgroundColor(color),
                  );
                },
              ),
              
              // Font family
              ListTile(
                title: const Text('Phông chữ'),
                subtitle: Text(settings.subtitleFontFamily),
                onTap: () {
                  _showFontPicker(context, settings);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color initialColor,
    Function(Color) onColorChanged,
  ) {
    final presetColors = [
      Colors.white,
      Colors.yellow,
      Colors.cyan,
      Colors.lime,
      Colors.orange,
      Colors.pink,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetColors.map((color) {
            return GestureDetector(
              onTap: () {
                onColorChanged(color);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: initialColor == color ? Colors.black : Colors.grey,
                    width: initialColor == color ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _showFontPicker(BuildContext context, AppSettings settings) {
    final presetFonts = [
      'Roboto',
      'Arial',
      'Times New Roman',
      'Courier New',
      'Verdana',
      'Georgia',
      'Palatino',
      'Garamond',
      'Bookman',
      'Comic Sans MS',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn phông chữ'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: presetFonts.length,
            itemBuilder: (context, index) {
              final font = presetFonts[index];
              return ListTile(
                title: Text(
                  font,
                  style: TextStyle(fontFamily: font),
                ),
                trailing: settings.subtitleFontFamily == font
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  settings.setSubtitleFontFamily(font);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}