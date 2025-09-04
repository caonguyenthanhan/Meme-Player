## Hướng dẫn chạy Meme Player

Tài liệu ngắn gọn để chạy ứng dụng trên Desktop (Windows) và Mobile (Android).

### 1) Cấu trúc dự án
- Thư mục `meme_player/`: Ứng dụng Flutter đa nền tảng (Windows, macOS, Linux, Android, iOS).
- Thư mục `mobile_app/`: Ứng dụng Android gốc (Kotlin) độc lập (không bắt buộc dùng nếu đã chạy Flutter app).

### 2) Yêu cầu môi trường
- Windows 10/11 (đã cài đặt PowerShell).
- Flutter SDK (khuyến nghị Flutter 3.x). Nếu đã có Flutter trên máy, dùng SDK hệ thống. Nếu chưa có, bạn có thể dùng SDK đi kèm trong `meme_player/flutter` (Windows).
- Android SDK + ADB (để chạy trên thiết bị/giả lập Android).

Kiểm tra Flutter:
```bash
flutter --version
```

Nếu chưa có `flutter` trong PATH, có thể tạm dùng SDK đi kèm:
```powershell
cd "meme_player/flutter/bin"
./flutter.bat --version
```

### 3) Chạy ứng dụng Flutter (Desktop & Mobile)
Làm việc trong thư mục `meme_player/`:
```powershell
cd "meme_player"
flutter pub get
```

• Chạy trên Windows Desktop:
```powershell
flutter config --enable-windows-desktop
flutter devices | cat
flutter run -d windows
```

• Chạy trên Android (thiết bị thật/giả lập đã bật):
```powershell
flutter devices | cat
flutter run -d android
```

• Chạy trên Web (tùy chọn):
```powershell
flutter config --enable-web
flutter run -d chrome
```

Ghi chú:
- Quyền truy cập thư mục: dùng chức năng "Mở thư mục" trong màn hình chính để quét và chọn tệp media.
- Ghim cửa sổ (Always-on-top): khả dụng trên Desktop. Nút ghim nằm trên `AppBar`.
- Tua: có 10s, 1 phút, 10 phút (tiến/lùi) bằng các nút nổi phía dưới.
- Tốc độ: mở nút tốc độ (icon đồng hồ) để chỉnh Slider 0.1x–10x, nút ±0.1/±0.25, và các preset.
- Phụ đề: đặt file `.srt` cùng tên cạnh file video, ứng dụng sẽ tự phát hiện. Vào nút phụ đề để tuỳ chỉnh màu, kích thước, phông, nền. Tốc độ phụ đề tự đồng bộ với tốc độ phát.
- Danh sách phát (playlist): khi mở từ "Thư mục" hoặc danh sách "Gần đây", có nút Trước/ Tiếp (prev/next) trên `AppBar` của màn hình trình phát.

### 4) Build gói phát hành nhanh
• Windows (debug → release exe đơn giản):
```powershell
flutter build windows
```
File tạo tại: `meme_player/build/windows/runner/Release/`.

• Android (APK):
```powershell
flutter build apk --release
```
File tạo tại: `meme_player/build/app/outputs/flutter-apk/app-release.apk`.

### 5) Ứng dụng Android gốc (tùy chọn)
Nếu muốn chạy project `mobile_app/` (Kotlin) độc lập:
```powershell
cd "mobile_app"
./gradlew assembleDebug
```
APK debug nằm trong `mobile_app/app/build/outputs/apk/debug/`.

### 6) Câu hỏi thường gặp
- Không thấy phụ đề hiển thị? Đảm bảo file `.srt` cùng tên với video và đặt cùng thư mục; hoặc kiểm tra quyền đọc file.
- Không thấy thiết bị Android? Chạy `adb devices`, bật USB debugging, mở giả lập hoặc cắm cáp USB.
- Lỗi desktop window_manager? Đảm bảo chạy trên Windows/máy bàn; các lệnh enable desktop đã bật: `flutter config --enable-windows-desktop`.

### 7) Kế hoạch tiện ích trình duyệt (WebExtension)
Chưa kèm sẵn. Nếu cần, sẽ cung cấp `manifest.json`, content script để điều khiển video HTML5/YouTube, và popup UI.


