# Meme Player

Ứng dụng xem video và nghe nhạc đa nền tảng, hoạt động trên cả máy tính (desktop app) và điện thoại (mobile app).

## Tính năng

### Giao diện và Điều khiển Cơ bản
- Hỗ trợ đa định dạng: mp4, m4a, mkv, mp3, và các định dạng phổ biến khác.
- Giao diện truyền thống: Các nút điều khiển cơ bản (phát/tạm dừng, tiếp theo, trước đó).
- Thanh tiến trình: Hiển thị thời gian và vị trí hiện tại của video/âm thanh.

### Chức năng Nâng cao
- Tua video:
  - Tiến/lùi: 10 giây, 30 giây.
- Điều chỉnh tốc độ phát:
  - Thanh kéo (slider) từ 0.1x đến 10x.
  - Các nút bấm cho các giá trị cố định: 0.1, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 5, 10.
  - Nút cộng (+) và trừ (-) để tăng/giảm mỗi 0.1x và 0.25x.
- Quản lý phụ đề:
  - Hỗ trợ đọc file phụ đề .srt, .vtt, .sub, .ass, .ssa.
  - Hiển thị phụ đề dưới video.
  - Tùy chỉnh: kích thước, phông chữ, màu sắc, và hiệu ứng.
  - Tốc độ phụ đề tự động đồng bộ với tốc độ phát video.
- Mở tệp tin từ thư mục:
  - Cho phép người dùng duyệt và mở các tệp media trong một thư mục cụ thể.
- Ghim màn hình:
  - Tính năng "luôn hiển thị trên cùng" (always-on-top) cho cửa sổ video trên desktop.

### Hệ thống Plugin
- Tự động phụ đề: Tự động tìm và tải phụ đề cùng tên với video.
- Nâng cao chất lượng video: Điều chỉnh độ sáng, độ tương phản, độ sắc nét.
- Nâng cao chất lượng âm thanh: Điều chỉnh bass, treble, giảm tiếng ồn.
- Giao diện tối: Tùy chỉnh giao diện tối cho ứng dụng.
- Tối ưu hóa hệ thống: Quản lý bộ nhớ cache và hiệu suất ứng dụng.

## Hướng dẫn cài đặt và chạy ứng dụng

### Yêu cầu
- Flutter SDK (phiên bản 3.0.0 trở lên)
- Dart SDK (phiên bản 2.19.0 trở lên)
- Android Studio (để phát triển cho Android)
- Xcode (chỉ dành cho macOS, để phát triển cho iOS)
- Visual Studio (cho Windows, để phát triển ứng dụng desktop)

### Cài đặt phụ thuộc
```bash
flutter pub get
```

### Chạy ứng dụng trên các nền tảng

#### Ứng dụng di động (Mobile App)

**Android:**
```bash
flutter run -d android
```

**iOS (chỉ trên macOS):**
```bash
flutter run -d ios
```

#### Ứng dụng desktop

**Windows:**
```bash
flutter run -d windows
```

**macOS (chỉ trên macOS):**
```bash
flutter run -d macos
```

**Linux:**
```bash
flutter run -d linux
```

### Tạo file .exe cho Windows

1. Đảm bảo đã cài đặt Visual Studio với các thành phần phát triển desktop C++
2. Chạy lệnh sau để tạo file .exe:

```bash
flutter build windows
```

3. File .exe sẽ được tạo tại đường dẫn: `build\windows\runner\Release\meme_player.exe`
4. Để tạo bản cài đặt, bạn có thể sử dụng các công cụ như Inno Setup:

```bash
# Cài đặt Inno Setup
# Tạo script cài đặt và biên dịch
```

### Quản lý Plugin

Meme Player sử dụng hệ thống plugin để mở rộng chức năng. Các plugin được đặt trong thư mục `lib/plugins/`.

#### Cách kích hoạt plugin

1. Mở ứng dụng Meme Player
2. Vào phần Cài đặt > Plugins
3. Bật/tắt các plugin theo nhu cầu

#### Phát triển plugin mới

Để phát triển plugin mới cho Meme Player:

1. Tạo một file Dart mới trong thư mục `lib/plugins/`
2. Kế thừa từ lớp `Plugin` trong `lib/models/plugin.dart`
3. Triển khai các phương thức cần thiết:
   - `onActivate()`: Được gọi khi plugin được kích hoạt
   - `onDeactivate()`: Được gọi khi plugin bị vô hiệu hóa
   - `configWidget()`: Widget cấu hình cho plugin
4. Đăng ký plugin trong `lib/services/plugin_service.dart`

```dart
// Ví dụ về plugin mới
class MyNewPlugin extends Plugin {
  MyNewPlugin() : super(
    id: 'my_new_plugin',
    name: 'My New Plugin',
    description: 'Mô tả về plugin mới',
    version: '1.0.0',
    type: PluginType.media,
  );
  
  @override
  void onActivate() {
    // Xử lý khi plugin được kích hoạt
  }
  
  @override
  void onDeactivate() {
    // Xử lý khi plugin bị vô hiệu hóa
  }
  
  @override
  Widget configWidget() {
    // Widget cấu hình cho plugin
    return Container();
  }
}
```

## Cấu trúc dự án

```
meme_player/
├── lib/
│   ├── main.dart                  # Điểm khởi đầu ứng dụng
│   ├── models/                    # Các model dữ liệu
│   │   ├── app_settings.dart      # Cài đặt ứng dụng
│   │   ├── media_file.dart        # Thông tin tệp media
│   │   └── plugin.dart            # Định nghĩa lớp Plugin cơ sở
│   ├── plugins/                   # Các plugin
│   │   ├── audio_enhancer_plugin.dart    # Plugin nâng cao âm thanh
│   │   ├── auto_subtitle_plugin.dart     # Plugin tự động phụ đề
│   │   ├── dark_theme_plugin.dart        # Plugin giao diện tối
│   │   ├── system_optimizer_plugin.dart  # Plugin tối ưu hệ thống
│   │   └── video_enhancer_plugin.dart    # Plugin nâng cao video
│   ├── screens/                   # Các màn hình
│   │   ├── advanced_settings_screen.dart  # Màn hình cài đặt nâng cao
│   │   ├── home_screen.dart              # Màn hình chính
│   │   ├── player_screen.dart            # Màn hình phát media
│   │   └── plugins_screen.dart           # Màn hình quản lý plugin
│   ├── services/                  # Các dịch vụ
│   │   ├── file_service.dart      # Dịch vụ quản lý tệp
│   │   ├── plugin_service.dart    # Dịch vụ quản lý plugin
│   │   ├── subtitle_service.dart  # Dịch vụ quản lý phụ đề
│   │   └── window_service.dart    # Dịch vụ quản lý cửa sổ
│   ├── utils/                     # Tiện ích
│   │   └── subtitle_utils.dart    # Tiện ích xử lý phụ đề
│   └── widgets/                   # Các widget tái sử dụng
│       ├── playback_speed_control.dart  # Điều khiển tốc độ phát
│       └── subtitle_control.dart        # Điều khiển phụ đề
├── assets/                        # Tài nguyên
│   └── images/                    # Hình ảnh
└── pubspec.yaml                   # Cấu hình dự án
```

## Kế hoạch phát triển

### Giai đoạn 1: Giao diện và Chức năng Cơ bản (Hoàn thành)
- Thiết kế UI/UX
- Phát triển lõi ứng dụng
- Hệ thống phát media
- Điều khiển cơ bản
- Thanh tiến trình

### Giai đoạn 2: Tích hợp Chức năng Nâng cao (Hoàn thành)
- Điều khiển tua
- Điều chỉnh tốc độ
- Tính năng phụ đề

### Giai đoạn 3: Tích hợp Hệ thống (Hoàn thành)
- Truy cập tệp tin
- Ghim màn hình

### Giai đoạn 4: Phát triển Tiện ích mở rộng (Hoàn thành)
- Kiến trúc tiện ích
- Hệ thống plugin
- Kết nối với ứng dụng

### Giai đoạn 5: Hoàn thiện và Kiểm thử (Hoàn thành)
- Tối ưu hiệu suất
- Xử lý lỗi
- Đóng gói sản phẩm

## Đóng góp

Chúng tôi rất hoan nghênh mọi đóng góp cho dự án Meme Player. Nếu bạn muốn đóng góp, vui lòng:

1. Fork dự án
2. Tạo nhánh tính năng (`git checkout -b feature/amazing-feature`)
3. Commit thay đổi của bạn (`git commit -m 'Add some amazing feature'`)
4. Push lên nhánh (`git push origin feature/amazing-feature`)
5. Mở Pull Request

## Giấy phép

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm thông tin.