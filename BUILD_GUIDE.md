# Hướng dẫn Build APK - Meme Player

## Scripts có sẵn

### 1. `auto_build_apk.ps1` - Build đầy đủ
**Chức năng:**
- Build cả debug và release APK
- Tự động clean project trước khi build
- Copy APK ra thư mục gốc với timestamp
- Tạo file "latest" cho phiên bản mới nhất
- Hiển thị thông tin chi tiết về build

**Cách sử dụng:**
```powershell
.\auto_build_apk.ps1
```

**Output files:**
- `memeplayer-debug-YYYYMMDD_HHMMSS.apk`
- `memeplayer-release-YYYYMMDD_HHMMSS.apk` (nếu có signing config)
- `memeplayer-debug-latest.apk`
- `memeplayer-release-latest.apk`

### 2. `quick_build.ps1` - Build nhanh
**Chức năng:**
- Chỉ build debug APK
- Không clean project (build nhanh hơn)
- Copy APK với timestamp
- Cập nhật file "latest"

**Cách sử dụng:**
```powershell
.\quick_build.ps1
```

**Output files:**
- `memeplayer-debug-YYYYMMDD_HHMMSS.apk`
- `memeplayer-debug-latest.apk`

### 3. `build_apk.ps1` - Script gốc
**Chức năng:**
- Script build cơ bản đã có sẵn
- Build và copy APK cơ bản

## Timestamp Format

Tất cả APK được đánh dấu với timestamp theo format:
- `YYYYMMDD_HHMMSS`
- Ví dụ: `20241225_143022` (25/12/2024 lúc 14:30:22)

## Lưu ý quan trọng

### Yêu cầu hệ thống:
- Windows với PowerShell
- Android SDK và Gradle đã cài đặt
- Java Development Kit (JDK)

### Trước khi build:
1. Đảm bảo Android Studio đã setup đúng
2. Kiểm tra file `local.properties` có đường dẫn SDK đúng
3. Đảm bảo có kết nối internet (để download dependencies)

### Signing Configuration:
- Debug APK: Tự động ký bằng debug keystore
- Release APK: Cần cấu hình signing trong `app/build.gradle.kts`

### Troubleshooting:

**Lỗi "gradlew not found":**
```powershell
# Chạy từ thư mục mobile_app
cd "d:\desktop\Meme Player\mobile_app"
.\gradlew assembleDebug
```

**Lỗi permission:**
```powershell
# Chạy PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Build failed:**
- Kiểm tra Android SDK path
- Chạy `gradlew clean` trước
- Kiểm tra kết nối internet
- Xem log chi tiết trong terminal

## Cấu trúc thư mục sau khi build

```
Meme Player/
├── auto_build_apk.ps1          # Script build đầy đủ
├── quick_build.ps1             # Script build nhanh
├── build_apk.ps1               # Script gốc
├── BUILD_GUIDE.md              # File hướng dẫn này
├── memeplayer-debug-latest.apk # APK debug mới nhất
├── memeplayer-release-latest.apk # APK release mới nhất
├── memeplayer-debug-20241225_143022.apk  # APK với timestamp
├── memeplayer-release-20241225_143022.apk
└── mobile_app/                 # Source code
    └── app/build/outputs/apk/  # APK gốc từ Gradle
```

## Tips sử dụng

1. **Development:** Dùng `quick_build.ps1` cho build nhanh trong quá trình phát triển
2. **Testing:** Dùng `auto_build_apk.ps1` để build đầy đủ trước khi test
3. **Distribution:** Dùng file `*-latest.apk` để luôn có phiên bản mới nhất
4. **Archive:** Các file có timestamp để lưu trữ các phiên bản cụ thể

## Automation

Có thể tạo scheduled task để tự động build:
```powershell
# Tạo task chạy hàng ngày lúc 2:00 AM
schtasks /create /tn "MemePlayer-AutoBuild" /tr "powershell.exe -File 'D:\desktop\Meme Player\auto_build_apk.ps1'" /sc daily /st 02:00
```