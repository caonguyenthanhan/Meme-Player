import 'package:flutter/material.dart';
import '../models/plugin.dart';
import '../models/media_file.dart';

class AudioEnhancerPlugin extends Plugin {
  // Các tùy chọn nâng cao chất lượng âm thanh
  bool _enhanceBass = true;
  bool _enhanceTreble = true;
  bool _reduceNoise = true;
  double _bassLevel = 0.3;
  double _trebleLevel = 0.2;
  double _noiseReductionLevel = 0.4;

  AudioEnhancerPlugin()
      : super(
          id: 'audio_enhancer',
          name: 'Nâng cao chất lượng âm thanh',
          description: 'Tự động cải thiện âm bass, treble và giảm tiếng ồn',
          version: '1.0.0',
          author: 'Meme Player Team',
          icon: Icons.graphic_eq,
          type: PluginType.audio,
          priority: 2,
        );

  // Getters cho các tùy chọn
  bool get enhanceBass => _enhanceBass;
  bool get enhanceTreble => _enhanceTreble;
  bool get reduceNoise => _reduceNoise;
  double get bassLevel => _bassLevel;
  double get trebleLevel => _trebleLevel;
  double get noiseReductionLevel => _noiseReductionLevel;

  // Setters cho các tùy chọn
  set enhanceBass(bool value) {
    _enhanceBass = value;
    notifyListeners();
  }

  set enhanceTreble(bool value) {
    _enhanceTreble = value;
    notifyListeners();
  }

  set reduceNoise(bool value) {
    _reduceNoise = value;
    notifyListeners();
  }

  set bassLevel(double value) {
    _bassLevel = value;
    notifyListeners();
  }

  set trebleLevel(double value) {
    _trebleLevel = value;
    notifyListeners();
  }

  set noiseReductionLevel(double value) {
    _noiseReductionLevel = value;
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
          'Tùy chỉnh nâng cao chất lượng âm thanh:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        
        // Tùy chọn âm bass
        Row(
          children: [
            Checkbox(
              value: _enhanceBass,
              onChanged: (value) {
                if (value != null) {
                  enhanceBass = value;
                }
              },
            ),
            const Text('Tăng cường âm bass'),
          ],
        ),
        if (_enhanceBass)
          Slider(
            value: _bassLevel,
            min: 0.0,
            max: 0.5,
            divisions: 10,
            label: 'Âm bass: ${(_bassLevel * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              bassLevel = value;
            },
          ),
        
        // Tùy chọn âm treble
        Row(
          children: [
            Checkbox(
              value: _enhanceTreble,
              onChanged: (value) {
                if (value != null) {
                  enhanceTreble = value;
                }
              },
            ),
            const Text('Tăng cường âm treble'),
          ],
        ),
        if (_enhanceTreble)
          Slider(
            value: _trebleLevel,
            min: 0.0,
            max: 0.5,
            divisions: 10,
            label: 'Âm treble: ${(_trebleLevel * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              trebleLevel = value;
            },
          ),
        
        // Tùy chọn giảm tiếng ồn
        Row(
          children: [
            Checkbox(
              value: _reduceNoise,
              onChanged: (value) {
                if (value != null) {
                  reduceNoise = value;
                }
              },
            ),
            const Text('Giảm tiếng ồn'),
          ],
        ),
        if (_reduceNoise)
          Slider(
            value: _noiseReductionLevel,
            min: 0.0,
            max: 0.5,
            divisions: 10,
            label: 'Mức giảm tiếng ồn: ${(_noiseReductionLevel * 100).toStringAsFixed(0)}%',
            onChanged: (value) {
              noiseReductionLevel = value;
            },
          ),
      ],
    );
  }

  @override
  Future<MediaFile> processVideo(MediaFile mediaFile) async {
    if (!isEnabled) return mediaFile;

    // Trong thực tế, đây là nơi bạn sẽ áp dụng các bộ lọc nâng cao chất lượng âm thanh
    // Ví dụ: sử dụng FFmpeg hoặc các thư viện xử lý âm thanh khác
    // Đối với mục đích demo, chúng ta chỉ cần trả về mediaFile không thay đổi
    
    // Thêm thông tin về các bộ lọc đã áp dụng vào metadata
    mediaFile.metadata['audio_enhancer'] = {
      'bass': _enhanceBass ? _bassLevel : 0,
      'treble': _enhanceTreble ? _trebleLevel : 0,
      'noise_reduction': _reduceNoise ? _noiseReductionLevel : 0,
    };

    return mediaFile;
  }
}