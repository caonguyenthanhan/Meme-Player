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
    // In a real app, this would show a color picker
    // For now, we'll just show a simple dialog with some preset colors
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn màu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _colorButton(context, Colors.white, onColorChanged),
              _colorButton(context, Colors.yellow, onColorChanged),
              _colorButton(context, Colors.green, onColorChanged),
              _colorButton(context, Colors.blue, onColorChanged),
              _colorButton(context, Colors.red, onColorChanged),
              _colorButton(context, Colors.black, onColorChanged),
            ],
          ),
        );
      },
    );
  }

  Widget _colorButton(
    BuildContext context,
    Color color,
    Function(Color) onColorChanged,
  ) {
    return InkWell(
      onTap: () {
        onColorChanged(color);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        height: 40,
        color: color,
        child: Center(
          child: Text(
            color.toString(),
            style: TextStyle(
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context, AppSettings settings) {
    final fonts = [
      'Arial',
      'Times New Roman',
      'Courier New',
      'Roboto',
      'Open Sans',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn phông chữ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: fonts.map((font) {
              return ListTile(
                title: Text(
                  font,
                  style: TextStyle(fontFamily: font),
                ),
                onTap: () {
                  settings.setSubtitleFontFamily(font);
                  Navigator.pop(context);
                },
                selected: settings.subtitleFontFamily == font,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}