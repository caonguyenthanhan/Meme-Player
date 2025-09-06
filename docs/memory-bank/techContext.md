# Tech Context - Meme Player

## Công nghệ chính

### Mobile App (Android)
- **Ngôn ngữ**: Kotlin
- **Framework phát media**: ExoPlayer
- **UI Framework**: AndroidX, Material Design
- **Gesture Handling**: GestureDetector
- **Picture-in-Picture**: Android PiP API
- **File Access**: Android Storage Access Framework

### Desktop App (Flutter)
- **Framework**: Flutter
- **Media Player**: video_player plugin
- **File Handling**: file_picker plugin
- **Subtitle**: subtitle plugin
- **Path Management**: path_provider plugin

### Browser Extension
- **Languages**: JavaScript, HTML, CSS
- **Build Tool**: npm
- **Target**: Chrome, Firefox, Edge

## Yêu cầu hệ thống

### Android
- **Minimum SDK**: API 23 (Android 6.0)
- **Target SDK**: API 34 (Android 14)
- **RAM**: Tối thiểu 100MB
- **Permissions**: 
  - READ_EXTERNAL_STORAGE
  - WRITE_EXTERNAL_STORAGE
  - WAKE_LOCK (giữ màn hình sáng)
  - SYSTEM_ALERT_WINDOW (PiP)

### Desktop
- **Flutter**: 3.0+
- **Platforms**: Windows, macOS, Linux
- **RAM**: Tối thiểu 512MB

## Cấu trúc dự án

### Mobile App Structure
```
mobile_app/
├── app/
│   ├── src/main/
│   │   ├── java/com/example/memeplayer/
│   │   │   ├── MainActivity.kt
│   │   │   ├── VideoPlayerActivity.kt
│   │   │   ├── models/
│   │   │   ├── services/
│   │   │   └── utils/
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   ├── values/
│   │   │   └── drawable/
│   │   └── AndroidManifest.xml
│   └── build.gradle.kts
├── gradle/
└── build.gradle.kts
```

### Desktop App Structure
```
meme_player/
├── lib/
│   ├── screens/
│   ├── widgets/
│   ├── models/
│   ├── services/
│   └── utils/
├── assets/
├── pubspec.yaml
└── pubspec.lock
```

## Dependencies chính

### Android (build.gradle.kts)
```kotlin
dependencies {
    implementation("androidx.media3:media3-exoplayer:1.2.0")
    implementation("androidx.media3:media3-ui:1.2.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("com.google.android.material:material:1.10.0")
}
```

### Flutter (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  video_player: ^2.7.2
  file_picker: ^6.1.1
  subtitle: ^1.0.0
  path_provider: ^2.1.1
```

## Thiết lập phát triển

### Android Development
- **IDE**: Android Studio
- **Build System**: Gradle with Kotlin DSL
- **Testing**: JUnit, Espresso
- **Debugging**: Logcat, Android Profiler

### Flutter Development
- **IDE**: VS Code, Android Studio
- **Hot Reload**: Enabled
- **Testing**: Flutter test framework
- **Debugging**: Flutter Inspector

## Ràng buộc kỹ thuật

### Performance
- Smooth 60fps playback
- Low memory footprint
- Fast startup time (<2s)

### Compatibility
- Support major video formats (MP4, MKV, AVI)
- Support major audio formats (MP3, M4A, WAV, FLAC)
- SRT subtitle format support

### Security
- No network permissions for core functionality
- Local file access only
- No data collection

## Build và Deployment

### Android Build Commands
```bash
# Debug build
./gradlew assembleDebug

# Release build
./gradlew assembleRelease

# Install debug
./gradlew installDebug
```

### Flutter Build Commands
```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Patterns và Best Practices

### Code Organization
- MVVM pattern cho Android
- Widget composition cho Flutter
- Separation of concerns
- Clean architecture principles

### Error Handling
- Graceful degradation
- User-friendly error messages
- Comprehensive logging
- Crash reporting

### Testing Strategy
- Unit tests cho business logic
- Integration tests cho UI flows
- Performance testing
- Device compatibility testing