# Meme Player - Ứng dụng Android

## Giới thiệu
Đây là phiên bản Android của ứng dụng Meme Player, cho phép người dùng xem và quản lý các video meme trên thiết bị di động.

## Tính năng
- Xem danh sách video meme
- Quản lý playlist
- Hỗ trợ các plugin nâng cao: tự động tạo phụ đề, nâng cao chất lượng video và âm thanh
- Giao diện người dùng thân thiện với chế độ tối

## Cài đặt và chạy ứng dụng

### Yêu cầu
- Android Studio Iguana | 2023.2.1 trở lên
- JDK 11 trở lên
- Android SDK 24 trở lên

### Cách chạy ứng dụng
1. Mở dự án trong Android Studio
2. Đồng bộ Gradle files
3. Kết nối thiết bị Android hoặc sử dụng máy ảo
4. Nhấn nút Run (▶️) để chạy ứng dụng

## Cấu trúc dự án
```
app/
├── src/
│   ├── main/
│   │   ├── java/com/example/memeplayer/
│   │   │   ├── adapters/         # Các adapter cho RecyclerView
│   │   │   ├── fragments/        # Các fragment cho màn hình chính
│   │   │   ├── models/           # Các model dữ liệu
│   │   │   └── MainActivity.kt   # Activity chính
│   │   ├── res/
│   │   │   ├── drawable/         # Các icon và hình ảnh
│   │   │   ├── layout/           # Các file layout XML
│   │   │   ├── menu/             # Các menu
│   │   │   └── values/           # Strings, colors, themes
│   │   └── AndroidManifest.xml   # Cấu hình ứng dụng
│   ├── androidTest/              # Unit tests cho Android
│   └── test/                     # Unit tests
├── build.gradle.kts              # Cấu hình build
└── proguard-rules.pro            # Cấu hình ProGuard
```

## Phát triển

### Thêm tính năng mới
1. Tạo các model cần thiết trong thư mục `models`
2. Tạo layout XML trong thư mục `res/layout`
3. Tạo adapter nếu cần trong thư mục `adapters`
4. Tạo fragment hoặc activity mới
5. Cập nhật navigation và menu nếu cần

### Thêm plugin mới
Để thêm plugin mới cho ứng dụng:
1. Tạo class plugin mới trong package riêng
2. Đăng ký plugin trong hệ thống plugin
3. Thêm UI điều khiển trong màn hình Settings

## Liên hệ
Nếu có bất kỳ câu hỏi hoặc đóng góp nào, vui lòng liên hệ với nhóm phát triển.