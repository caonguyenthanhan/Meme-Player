# Hướng dẫn chạy Meme Player Desktop App

## Yêu cầu hệ thống

### Windows
- Windows 10 (version 1903) trở lên
- RAM: 4GB trở lên
- Ổ cứng: 2GB trống
- .NET Framework 4.7.2 trở lên

### macOS
- macOS 10.14 (Mojave) trở lên
- RAM: 4GB trở lên
- Ổ cứng: 2GB trống

### Linux
- Ubuntu 18.04 trở lên hoặc tương đương
- RAM: 4GB trở lên
- Ổ cứng: 2GB trống
- Các thư viện cần thiết: `libgtk-3-dev`, `libblkid-dev`, `liblzma-dev`

## Cài đặt Flutter

### 1. Tải Flutter SDK
```bash
# Windows: Tải từ https://flutter.dev/docs/get-started/install/windows
# macOS: Sử dụng Homebrew
brew install flutter

# Linux: Sử dụng snap
sudo snap install flutter --classic
```

### 2. Kiểm tra cài đặt
```bash
flutter doctor
```

### 3. Cài đặt dependencies
```bash
flutter pub get
```

## Chạy ứng dụng

### Chế độ Debug (Development)
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Chế độ Release (Production)
```bash
# Windows
flutter build windows
flutter run -d windows --release

# macOS
flutter build macos
flutter run -d macos --release

# Linux
flutter build linux
flutter run -d linux --release
```

## Tính năng chính

### 🎬 Phát media
- Hỗ trợ: MP4, MKV, AVI, MOV, WMV, FLV, MP3, M4A, WAV, FLAC
- Tự động nhận diện file phụ đề .srt
- Phát playlist từ thư mục

### ⏯️ Điều khiển phát
- **Seek buttons**: 10s, 1 phút, 10 phút (tiến/lùi)
- **Timeline**: Kéo để seek chính xác
- **Play/Pause**: Nút điều khiển trung tâm
- **Tốc độ**: 0.1x đến 10x với preset buttons

### 🎭 Phụ đề
- Đọc file .srt tự động
- Tùy chỉnh: kích thước, font, màu sắc, nền
- Đồng bộ với tốc độ phát

### 🔄 Giao diện
- **Always-on-top**: Luôn hiển thị trên cùng
- **Fullscreen**: Chế độ toàn màn hình
- **Dark/Light theme**: Tự động theo hệ thống
- **Responsive**: Tối ưu cho mọi kích thước màn hình

## Cách sử dụng

### Mở file media
1. **Mở file đơn**: Nhấn "Mở file" → Chọn file video/audio
2. **Mở thư mục**: Nhấn "Mở thư mục" → Chọn thư mục chứa media
3. **Từ Recent**: Chọn từ danh sách tệp gần đây

### Điều khiển phát
- **Tap màn hình**: Hiện/ẩn điều khiển
- **Nút seek**: Nhấn để tua nhanh/lùi
- **Timeline**: Kéo để seek chính xác
- **Tốc độ**: Sử dụng nút +/- hoặc preset

### Cài đặt
- **Settings**: Tùy chỉnh giao diện và phụ đề
- **Plugins**: Quản lý các plugin nâng cao
- **Theme**: Chuyển đổi sáng/tối

## Xử lý sự cố

### Lỗi thường gặp

**Flutter không được cài đặt**
```bash
flutter doctor
# Làm theo hướng dẫn để cài đặt dependencies còn thiếu
```

**Không build được Windows**
```bash
# Cài đặt Visual Studio với C++ development tools
flutter config --enable-windows-desktop
flutter create . --platforms=windows
```

**Không build được macOS**
```bash
# Cài đặt Xcode từ App Store
flutter config --enable-macos-desktop
flutter create . --platforms=macos
```

**Không build được Linux**
```bash
# Cài đặt dependencies
sudo apt-get install libgtk-3-dev libblkid-dev liblzma-dev
flutter config --enable-linux-desktop
flutter create . --platforms=linux
```

**Ứng dụng không chạy**
```bash
flutter clean
flutter pub get
flutter run -d windows  # hoặc macos/linux
```

### Build APK cho mobile (tùy chọn)
```bash
flutter build apk --release
# APK sẽ được tạo tại: build/app/outputs/flutter-apk/app-release.apk
```

## Cấu trúc dự án

```
meme_player/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── screens/                  # Màn hình chính
│   │   ├── home_screen.dart      # Màn hình chào mừng
│   │   ├── player_screen.dart    # Màn hình phát video
│   │   └── ...
│   ├── widgets/                  # Widget tùy chỉnh
│   │   ├── playback_speed_control.dart
│   │   ├── subtitle_control.dart
│   │   └── preset_speed_buttons.dart
│   ├── models/                   # Model dữ liệu
│   ├── services/                 # Dịch vụ
│   └── utils/                    # Tiện ích
├── assets/                       # Tài nguyên
├── windows/                      # Windows-specific code
├── macos/                        # macOS-specific code
├── linux/                        # Linux-specific code
└── pubspec.yaml                  # Dependencies
```

## Tùy chỉnh

### Thay đổi theme
```dart
// Trong lib/main.dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.red, // Thay đổi màu chủ đạo
  brightness: Brightness.light,
),
```

### Thêm định dạng file mới
```yaml
# Trong pubspec.yaml
dependencies:
  video_player: ^2.7.0
  chewie: ^1.7.0
```

### Tùy chỉnh giao diện
```dart
// Trong lib/screens/player_screen.dart
// Thay đổi kích thước, màu sắc, layout
```

## Liên hệ hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra `flutter doctor` output
2. Xem log lỗi trong terminal
3. Kiểm tra Flutter version: `flutter --version`
4. Gửi thông tin lỗi chi tiết

---

**Lưu ý**: Desktop app được thiết kế để hoạt động tốt nhất trên màn hình có độ phân giải 1920x1080 trở lên.
