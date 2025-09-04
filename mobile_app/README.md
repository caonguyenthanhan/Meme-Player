# Meme Player - Ứng dụng Android

Ứng dụng phát video/audio đa năng với giao diện thân thiện và nhiều tính năng nâng cao.

## Tính năng chính

### 🎬 Phát media
- Hỗ trợ nhiều định dạng: MP4, MKV, AVI, MP3, M4A, WAV...
- Phát video với chất lượng cao
- Tự động nhận diện file media từ ứng dụng khác

### ⏯️ Điều khiển phát
- Play/Pause
- Tua nhanh/lùi: 10s, 1 phút, 10 phút
- Thanh timeline với seek chính xác
- Điều chỉnh tốc độ: 0.1x đến 10x
- Nút preset: 0.1, 0.5, 0.75, 1, 1.5, 1.75, 2, 2.5, 3, 5, 10x
- Nút +/- 0.1x và +/- 0.25x

### 🎭 Phụ đề
- Hỗ trợ file .srt
- Hiển thị phụ đề đồng bộ với tốc độ phát
- Bật/tắt phụ đề bằng cách nhấn giữ
- Tự động ẩn khi không có phụ đề

### 🎮 Điều khiển cử chỉ
- **Vuốt dọc bên trái**: Điều chỉnh độ sáng màn hình
- **Vuốt dọc bên phải**: Điều chỉnh âm lượng
- **Vuốt ngang**: Tua nhanh/lùi
- **Double tap trái/phải**: Lùi/tiến 10 giây
- **Nhấn giữ trái/phải**: Tua nhanh liên tục

### 🔄 Giao diện
- Xoay màn hình tự động
- Chế độ Picture-in-Picture (PiP)
- Giao diện tối ưu cho điện thoại FullHD
- Tự động ẩn điều khiển sau khi không sử dụng

## Cài đặt

### Yêu cầu hệ thống
- Android 6.0 (API 23) trở lên
- Tối thiểu 100MB RAM
- Quyền truy cập file và âm thanh

### Cài đặt APK
1. Tải file APK từ thư mục `app/build/outputs/apk/release/`
2. Bật "Cài đặt từ nguồn không xác định" trong Cài đặt > Bảo mật
3. Mở file APK và làm theo hướng dẫn cài đặt

### Build từ source
```bash
# Clone repository
git clone <repository-url>
cd mobile_app

# Build APK
./gradlew assembleRelease

# Cài đặt debug
./gradlew installDebug
```

## Sử dụng

### Mở file media
1. **Từ ứng dụng khác**: Chọn "Mở với" > Meme Player
2. **Từ file manager**: Nhấn vào file video/audio > Chọn Meme Player

### Điều khiển cơ bản
- **Tap màn hình**: Hiện/ẩn điều khiển
- **Nút Play/Pause**: Phát/tạm dừng
- **Nút seek**: Tua nhanh/lùi theo thời gian
- **Thanh timeline**: Kéo để seek chính xác

### Điều chỉnh tốc độ
- **Thanh kéo**: Kéo để điều chỉnh từ 0.1x đến 10x
- **Nút preset**: Nhấn để chọn tốc độ cố định
- **Nút +/-**: Tăng/giảm 0.1x hoặc 0.25x

### Phụ đề
1. Nhấn "Chọn phụ đề (.srt)"
2. Chọn file .srt từ bộ nhớ
3. Phụ đề sẽ hiển thị tự động
4. Nhấn giữ vùng phụ đề để bật/tắt

### Cử chỉ
- **Vuốt dọc**: Điều chỉnh độ sáng/âm lượng
- **Vuốt ngang**: Tua nhanh
- **Double tap**: Tua 10s
- **Nhấn giữ**: Tua liên tục

## Cấu trúc dự án

```
mobile_app/
├── app/
│   ├── src/main/
│   │   ├── java/com/example/memeplayer/
│   │   │   ├── MainActivity.kt          # Màn hình chính
│   │   │   ├── VideoPlayerActivity.kt   # Màn hình phát video
│   │   │   └── ...
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   ├── activity_main.xml
│   │   │   │   └── activity_video_player.xml
│   │   │   └── ...
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
├── gradle/
└── build.gradle
```

## Công nghệ sử dụng

- **Kotlin**: Ngôn ngữ lập trình chính
- **ExoPlayer**: Thư viện phát media
- **AndroidX**: Thư viện UI hiện đại
- **GestureDetector**: Xử lý cử chỉ
- **Picture-in-Picture**: Chế độ phát nhỏ

## Xử lý sự cố

### Lỗi thường gặp

**Ứng dụng không mở được file video**
- Kiểm tra quyền truy cập file
- Đảm bảo định dạng file được hỗ trợ
- Thử mở từ ứng dụng khác với "Mở với"

**Phụ đề không hiển thị**
- Kiểm tra file .srt có đúng định dạng
- Đảm bảo file phụ đề cùng thư mục với video
- Thử file phụ đề khác

**Điều khiển không ẩn**
- Tap màn hình để hiện/ẩn
- Chờ 3 giây để tự động ẩn
- Kiểm tra cài đặt hệ thống

### Báo lỗi
Nếu gặp lỗi, vui lòng:
1. Ghi lại thông báo lỗi chính xác
2. Mô tả các bước gây lỗi
3. Thông tin thiết bị (Android version, model)
4. Gửi log từ Logcat nếu có thể

## Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:
1. Fork dự án
2. Tạo branch mới cho tính năng
3. Commit thay đổi
4. Tạo Pull Request

## Giấy phép

Dự án này được phát hành dưới giấy phép MIT. Xem file LICENSE để biết thêm chi tiết.

## Liên hệ

- **Tác giả**: Meme Player Team
- **Email**: support@memeplayer.com
- **GitHub**: https://github.com/memeplayer/android

---

**Lưu ý**: Ứng dụng này được thiết kế để hoạt động tốt nhất trên thiết bị Android hiện đại với màn hình FullHD trở lên.