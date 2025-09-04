# Meme Player - Ứng dụng phát media đa nền tảng

Ứng dụng phát video/audio chuyên nghiệp với giao diện hiện đại và nhiều tính năng nâng cao, hỗ trợ cả desktop và mobile.

## 🌟 Tính năng nổi bật

### 🎬 Phát media đa định dạng
- **Video**: MP4, MKV, AVI, MOV, WMV, FLV
- **Audio**: MP3, M4A, WAV, FLAC, OGG, AAC
- **Phụ đề**: SRT với tùy chỉnh đầy đủ

### ⏯️ Điều khiển phát nâng cao
- Tua nhanh/lùi: 10s, 1 phút, 10 phút
- Điều chỉnh tốc độ: 0.1x đến 10x
- Nút preset tốc độ thông minh
- Thanh timeline với seek chính xác

### 🎭 Quản lý phụ đề
- Đọc file .srt tự động
- Đồng bộ với tốc độ phát
- Tùy chỉnh: kích thước, font, màu sắc, hiệu ứng
- Bật/tắt linh hoạt

### 🎮 Điều khiển cử chỉ (Mobile)
- Vuốt dọc: Điều chỉnh độ sáng/âm lượng
- Vuốt ngang: Tua nhanh
- Double tap: Tua 10s
- Nhấn giữ: Tua liên tục

### 🔄 Giao diện thông minh
- **Desktop**: Luôn ở trên cùng, giao diện tối ưu
- **Mobile**: Responsive, xoay màn hình, Picture-in-Picture
- Tự động ẩn điều khiển
- Chế độ tối/sáng

## 🚀 Cài đặt và chạy

### Desktop (Flutter)
```bash
cd meme_player
flutter pub get
flutter run -d windows  # Windows
flutter run -d macos    # macOS
flutter run -d linux    # Linux
```

### Mobile (Android)
```bash
cd mobile_app
./gradlew assembleRelease  # Build APK
./gradlew installDebug     # Cài đặt debug
```

### Web Extension (Chrome/Firefox)
```bash
cd browser_extension
npm install
npm run build
# Load extension vào trình duyệt
```

## 📱 Các phiên bản

### 🖥️ Desktop App (Flutter)
- Giao diện hiện đại với Material Design
- Hỗ trợ đa nền tảng: Windows, macOS, Linux
- Luôn ở trên cùng (Always-on-top)
- Quản lý playlist và thư mục

### 📱 Mobile App (Android)
- Giao diện tối ưu cho điện thoại
- Điều khiển cử chỉ đa dạng
- Picture-in-Picture mode
- Tự động nhận diện file media

### 🌐 Browser Extension
- Tích hợp với YouTube và các trang web video
- Sử dụng công cụ phát từ ứng dụng chính
- Hỗ trợ Chrome, Firefox, Edge

## 🛠️ Công nghệ sử dụng

### Desktop & Mobile
- **Flutter**: Framework chính cho desktop
- **Kotlin**: Ngôn ngữ cho Android
- **ExoPlayer**: Thư viện phát media Android
- **video_player**: Thư viện phát media Flutter

### Phụ đề & Media
- **subtitle**: Xử lý file SRT
- **file_picker**: Chọn file từ hệ thống
- **path_provider**: Quản lý đường dẫn

### Giao diện & UX
- **Material Design**: Thiết kế UI nhất quán
- **Responsive Design**: Tối ưu cho mọi kích thước màn hình
- **Gesture Detection**: Xử lý cử chỉ touch

## 📁 Cấu trúc dự án

```
meme_player/
├── lib/                    # Flutter app (Desktop)
│   ├── screens/           # Màn hình chính
│   ├── widgets/           # Widget tùy chỉnh
│   ├── models/            # Model dữ liệu
│   └── services/          # Dịch vụ
├── mobile_app/            # Android app
│   ├── app/src/main/
│   │   ├── java/          # Kotlin source
│   │   ├── res/           # Resources
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
├── browser_extension/     # Web extension
│   ├── src/               # Source code
│   ├── manifest.json      # Extension manifest
│   └── package.json
└── docs/                  # Tài liệu
```

## 🎯 Roadmap

### ✅ Đã hoàn thành
- [x] Desktop app với Flutter
- [x] Mobile app với Android
- [x] Phát media đa định dạng
- [x] Điều khiển cơ bản
- [x] Hỗ trợ phụ đề SRT
- [x] Điều chỉnh tốc độ
- [x] Giao diện responsive

### 🔄 Đang phát triển
- [ ] Browser extension
- [ ] Quản lý playlist nâng cao
- [ ] Streaming support
- [ ] Cloud storage integration

### 📋 Kế hoạch tương lai
- [ ] iOS app
- [ ] Web app
- [ ] Plugin system
- [ ] AI-powered features

## 🐛 Xử lý sự cố

### Desktop
- **Không chạy được**: Kiểm tra Flutter installation
- **Lỗi dependencies**: Chạy `flutter pub get`
- **Build lỗi**: Kiểm tra platform support

### Mobile
- **Không mở file**: Kiểm tra quyền truy cập
- **Phụ đề lỗi**: Kiểm tra định dạng .srt
- **Giao diện to**: Đã tối ưu cho FullHD

### Browser Extension
- **Không load**: Kiểm tra manifest version
- **Không hoạt động**: Reload extension

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. **Fork** dự án
2. **Tạo branch** mới: `git checkout -b feature/amazing-feature`
3. **Commit** thay đổi: `git commit -m 'Add amazing feature'`
4. **Push** lên branch: `git push origin feature/amazing-feature`
5. **Tạo Pull Request**

### Hướng dẫn đóng góp
- Tuân thủ coding standards
- Viết test cho tính năng mới
- Cập nhật documentation
- Kiểm tra cross-platform compatibility

## 📄 Giấy phép

Dự án này được phát hành dưới giấy phép **MIT**. Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 🙏 Cảm ơn

- **Flutter Team**: Framework tuyệt vời
- **ExoPlayer**: Thư viện phát media Android
- **Cộng đồng open source**: Đóng góp và hỗ trợ

## 📞 Liên hệ

- **Website**: https://memeplayer.com
- **Email**: support@memeplayer.com
- **GitHub**: https://github.com/memeplayer
- **Discord**: https://discord.gg/memeplayer

---

**⭐ Nếu dự án này hữu ích, hãy cho chúng tôi một star!**

**Made with ❤️ by Meme Player Team**
