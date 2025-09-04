import 'package:flutter/material.dart';
import '../models/plugin.dart';
import '../models/media_file.dart';

class VideoEnhancerPlugin extends Plugin {
  // Các tùy chọn nâng cao chất lượng video
  bool _enhanceBrightness = true;
  bool _enhanceContrast = true;
  bool _enhanceSharpness = true;
  double _brightnessLevel = 0.2;
  double _contrastLevel = 0.2;
  double _sharpnessLevel = 0.3;

  VideoEnhancerPlugin()
      : super(
          id: 'video_enhancer',
          name: 'Nâng cao chất lượng video',
          description: 'Tự động cải thiện độ sáng, độ tương phản và độ sắc nét của video',
          version: '1.0.0',
          author: 'Meme Player Team',
          icon: Icons.auto_fix_high,
          type: PluginType.video,
          priority: 2,
        );

  // Getters cho các tùy chọn
  bool get enhanceBrightness => _enhanceBrightness;
  bool get enhanceContrast => _enhanceContrast;
  bool get enhanceSharpness => _enhanceSharpness;
  double get brightnessLevel => _brightnessLevel;
  double get contrastLevel => _contrastLevel;
  double get sharpnessLevel => _sharpnessLevel;

  // Setters cho các tùy chọn
  set enhanceBrightness(bool value) {
    _enhanceBrightness = value;
    notifyListeners();
  }

  set enhanceContrast(bool value) {
    _enhanceContrast = value;
    notifyListeners();
  }

  set enhanceSharpness(bool value) {
    _enhanceSharpness = value;
    notifyListeners();
  }

  set brightnessLevel(double value) {
    _brightnessLevel = value;
    notifyListeners();
  }

  set contrastLevel(double value) {
    _contrastLevel = value;
    notifyListeners();
  }

  set sharpnessLevel(double value) {
    _sharpnessLevel = value;
    notifyListeners();
  }

  @override
  Future<void> onActivate() async {
    // Không cần làm gì khi kích hoạt
  }

  @override
  Future<void> onDeactivate() async {
    // Không cần làm gì khi vô hiệu hóa
  }

  @override
  Widget? configWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tùy chỉnh nâng cao chất lượng video:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        
        // Tùy chọn độ sáng
        Row(
          children: [
            Checkbox(
              value: _enhanceBrightness,
              onChanged: (value) {
                if (value != null) {
                  enhanceBrightness = value;
                }
              },
            ),
            const Text('Tăng cường độ sáng'),
          ],
        ),
        if (_enhanceBrightness)
          Slider(
            value: _brightnessLevel,
            min: 0.0,
            max: 0.5,
            divisions: 10,
            label: 'Độ sáng: ${(_brightnessLevel * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              brightnessLevel = value;
            },
          ),
        
        // Tùy chọn độ tương phản
        Row(
          children: [
            Checkbox(
              value: _enhanceContrast,
              onChanged: (value) {
                if (value != null) {
                  enhanceContrast = value;
                }
              },
            ),
            const Text('Tăng cường độ tương phản'),
          ],
        ),
        if (_enhanceContrast)
          Slider(
            value: _contrastLevel,
            min: 0.0,
            max: 0.5,
            divisions: 10,
            label: 'Độ tương phản: ${(_contrastLevel * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              contrastLevel = value;
            },
          ),
        
        // Tùy chọn độ sắc nét
        Row(
          children: [
            Checkbox(
              value: _enhanceSharpness,
              onChanged: (value) {
                if (value != null) {
                  enhanceSharpness = value;
                }
              },
            ),
            const Text('Tăng cường độ sắc nét'),
          ],
        ),
        if (_enhanceSharpness)
          Slider(
            value: _sharpnessLevel,
            min: 0.0,
            max: 0.5,
            divisions: 10,
            label: 'Độ sắc nét: ${(_sharpnessLevel * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              sharpnessLevel = value;
            },
          ),
      ],
    );
  }

  @override
  Future<MediaFile> processVideo(MediaFile mediaFile) async {
    if (!mediaFile.isVideo || !isEnabled) return mediaFile;

    // Trong thực tế, đây là nơi bạn sẽ áp dụng các bộ lọc nâng cao chất lượng video
    // Ví dụ: sử dụng FFmpeg hoặc các thư viện xử lý video khác
    // Đối với mục đích demo, chúng ta chỉ cần trả về mediaFile không thay đổi
    
    // Thêm thông tin về các bộ lọc đã áp dụng vào metadata
    mediaFile.metadata['video_enhancer'] = {
      'brightness': _enhanceBrightness ? _brightnessLevel : 0,
      'contrast': _enhanceContrast ? _contrastLevel : 0,
      'sharpness': _enhanceSharpness ? _sharpnessLevel : 0,
    };

    return mediaFile;
  }
}