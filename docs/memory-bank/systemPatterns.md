# System Patterns - Meme Player

## Kiến trúc tổng thể

### Multi-Platform Architecture
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Desktop App   │  │   Mobile App    │  │ Browser Extension│
│   (Flutter)     │  │   (Android)     │  │  (JavaScript)   │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                    ┌─────────────────┐
                    │  Shared Concepts │
                    │  - Media Playback│
                    │  - Subtitle Sync │
                    │  - Gesture Control│
                    └─────────────────┘
```

### Android App Architecture (MVVM)
```
┌─────────────────────────────────────────────────────────┐
│                        UI Layer                         │
│  ┌─────────────────┐  ┌─────────────────────────────────┐│
│  │   Activities    │  │           Fragments             ││
│  │ - MainActivity  │  │ - VideoPlayerFragment           ││
│  │ - VideoPlayer   │  │ - ControlsFragment              ││
│  │   Activity      │  │ - SubtitleFragment              ││
│  └─────────────────┘  └─────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────┐
│                    ViewModel Layer                      │
│  ┌─────────────────┐  ┌─────────────────────────────────┐│
│  │ VideoViewModel  │  │        PlayerViewModel          ││
│  │ - playback state│  │ - media controls                ││
│  │ - file info     │  │ - gesture handling              ││
│  │ - history       │  │ - subtitle management          ││
│  └─────────────────┘  └─────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────┐
│                     Service Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌───────────┐│
│  │ MediaService    │  │ HistoryService  │  │FileService││
│  │ - ExoPlayer     │  │ - SharedPrefs   │  │- File I/O ││
│  │ - playback      │  │ - playback log  │  │- Metadata ││
│  │ - subtitle sync │  │ - resume points │  │- Directory││
│  └─────────────────┘  └─────────────────┘  └───────────┘│
└─────────────────────────────────────────────────────────┘
```

## Core Design Patterns

### 1. Observer Pattern (Media Playback)
```kotlin
// MediaPlayerObserver interface
interface MediaPlayerObserver {
    fun onPlaybackStateChanged(state: PlaybackState)
    fun onPositionChanged(position: Long)
    fun onMediaEnded()
}

// Implementation in VideoPlayerActivity
class VideoPlayerActivity : MediaPlayerObserver {
    override fun onMediaEnded() {
        showEndVideoOptions() // Replay/Exit/Next
    }
}
```

### 2. Strategy Pattern (Gesture Handling)
```kotlin
interface GestureStrategy {
    fun handleGesture(gesture: GestureEvent)
}

class BrightnessGestureStrategy : GestureStrategy {
    override fun handleGesture(gesture: GestureEvent) {
        // Handle vertical swipe on left side
    }
}

class VolumeGestureStrategy : GestureStrategy {
    override fun handleGesture(gesture: GestureEvent) {
        // Handle vertical swipe on right side
    }
}
```

### 3. Repository Pattern (Data Management)
```kotlin
interface MediaRepository {
    suspend fun getPlaybackHistory(): List<MediaItem>
    suspend fun savePlaybackPosition(uri: String, position: Long)
    suspend fun getDirectoryVideos(path: String): List<VideoFile>
}

class LocalMediaRepository : MediaRepository {
    // Implementation using SharedPreferences and File system
}
```

### 4. Factory Pattern (Media Player Creation)
```kotlin
class MediaPlayerFactory {
    fun createPlayer(context: Context): ExoPlayer {
        return ExoPlayer.Builder(context)
            .setWakeMode(C.WAKE_MODE_LOCAL) // Keep screen on
            .build()
    }
}
```

## Component Relationships

### Media Playback Flow
```
File Selection → Intent Filter → MainActivity → VideoPlayerActivity
                                      ↓
                              MediaService.initialize()
                                      ↓
                              ExoPlayer.setMediaItem()
                                      ↓
                              Auto-play (new requirement)
                                      ↓
                              Update UI with video name
                                      ↓
                              Keep screen awake
                                      ↓
                              Save to history
```

### Gesture Control Flow
```
Touch Event → GestureDetector → GestureStrategy → Action
     ↓              ↓                ↓             ↓
MotionEvent → onTouchEvent → handleGesture → updateUI
```

### Subtitle Synchronization
```
SRT File → SubtitleParser → TimedText → PlayerSync → Display
    ↓           ↓              ↓           ↓          ↓
  Load → Parse timestamps → Create cues → Sync speed → Show
```

## Key Architectural Decisions

### 1. ExoPlayer vs MediaPlayer
**Decision**: Use ExoPlayer
**Reason**: 
- Better format support
- More reliable subtitle handling
- Better performance
- Active development

### 2. Activity vs Fragment for Video Player
**Decision**: Separate VideoPlayerActivity
**Reason**:
- Full-screen experience
- Better lifecycle management
- Easier orientation handling
- Independent from file browser

### 3. SharedPreferences vs Database
**Decision**: SharedPreferences for simple data
**Reason**:
- Lightweight for history and settings
- No complex relationships
- Fast access
- Simple implementation

### 4. Custom Gesture vs Standard
**Decision**: Custom GestureDetector implementation
**Reason**:
- Precise control over gesture areas
- Better user experience
- Customizable sensitivity
- Platform-specific optimizations

## Data Flow Patterns

### Unidirectional Data Flow
```
User Action → ViewModel → Service → Repository → Database/Preferences
     ↑                                                    ↓
UI Update ← Observer ← LiveData ← Service Response ← Data Change
```

### Event-Driven Architecture
```
Media Events → EventBus → Subscribers → UI Updates
     ↓             ↓           ↓           ↓
Playback → MediaPlayerEvents → ViewModels → Activities
```

## Error Handling Patterns

### Graceful Degradation
```kotlin
try {
    loadSubtitle(subtitleFile)
} catch (e: Exception) {
    // Continue without subtitle
    hideSubtitleControls()
    logError("Subtitle loading failed", e)
}
```

### Retry Pattern
```kotlin
class MediaLoader {
    suspend fun loadMedia(uri: String, retryCount: Int = 3) {
        repeat(retryCount) { attempt ->
            try {
                return loadMediaInternal(uri)
            } catch (e: Exception) {
                if (attempt == retryCount - 1) throw e
                delay(1000 * (attempt + 1)) // Exponential backoff
            }
        }
    }
}
```

## Performance Patterns

### Lazy Loading
```kotlin
class VideoMetadata {
    val thumbnail: Bitmap by lazy {
        generateThumbnail(videoPath)
    }
}
```

### Memory Management
```kotlin
override fun onDestroy() {
    super.onDestroy()
    mediaPlayer?.release()
    gestureDetector = null
    // Clear references to prevent leaks
}
```

## Security Patterns

### Input Validation
```kotlin
fun validateMediaFile(uri: Uri): Boolean {
    val mimeType = contentResolver.getType(uri)
    return SUPPORTED_MIME_TYPES.contains(mimeType)
}
```

### Permission Handling
```kotlin
fun requestStoragePermission() {
    if (ContextCompat.checkSelfPermission(this, READ_EXTERNAL_STORAGE) 
        != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(this, 
            arrayOf(READ_EXTERNAL_STORAGE), REQUEST_CODE)
    }
}
```