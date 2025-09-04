## Meme Player - Requirement Memory Bank

This living checklist tracks the planned features vs current implementation status.

### 1) Core UI and Controls
- **Multi-format support (mp4, m4a, mkv, mp3, etc.)**: PARTIAL
  - Implemented in `lib/models/media_file.dart` via `isSupportedVideoFormat` and `isSupportedAudioFormat` (mp4, mkv, avi, mov, wmv, flv, webm, m4v; mp3, wav, ogg, aac, m4a, flac, wma).
- **Traditional UI with basic controls (play/pause, next/prev)**: PARTIAL
  - Playback handled by Chewie/VideoPlayer in `lib/screens/player_screen.dart`. Custom skip buttons exist; explicit next/prev track logic not present.
- **Progress bar showing time/current position**: PARTIAL
  - Chewie provides a built-in progress bar; no custom progress widget detected.

### 2) Advanced Features
- **Seek/Skip (10s, 1m, 10m)**: PARTIAL
  - 10s and 30s implemented in `player_screen.dart` (`_skipForward/_skipBackward`). 1 minute and 10 minutes missing.
- **Playback speed adjustment**: MOSTLY COMPLETE
  - Slider 0.1x–10x, increments of 0.1 via divisions=99. Preset buttons include required values: 0.1, 0.5, 0.75, 1, 1.5, 1.75, 2, 2.5, 3, 5, 10 (plus 1.25). +/- buttons: -0.1, -0.25, +0.25, +0.1. Implemented in `lib/widgets/playback_speed_control.dart`. Persisted to settings via `AppSettings` from `player_screen.dart`.
- **Subtitle management (.srt)**: PARTIAL WITH BUGS
  - Parsing pipeline present: `lib/services/subtitle_service.dart` uses `subtitle` package and `lib/utils/subtitle_utils.dart` for discovery/parse. UI customization present in `lib/widgets/subtitle_control.dart` and stored in `AppSettings`.
  - Display: `player_screen.dart` currently uses a dummy Chewie `Subtitle` sample, not wired to `SubtitleService` or file-based `.srt`—no real-time text display from `.srt`.
  - Sync to playback speed supported conceptually by `SubtitleService.getSubtitleTextAtPosition(..., playbackSpeed)` but not integrated into the player UI render loop.
  - Settings bug: `AppSettings.subtitleColor` is a `String` but used as `Color` in `SubtitleControl` and `PlayerScreen` (type mismatch; will not compile).
- **Open files from a folder**: COMPLETE
  - Implemented via `file_picker` in `lib/screens/home_screen.dart` (`_openFolder`) and directory scan in `lib/services/file_service.dart`. Allows browsing and selecting discovered media.
- **Always-on-top (desktop)**: COMPLETE
  - Implemented via `window_manager` in `lib/services/window_service.dart` with UI toggles in `home_screen.dart` and `player_screen.dart`.

### 3) Technology Choices
- **Flutter cross-platform app**: PRESENT
  - Flutter app under `meme_player/`. Separate `mobile_app/` (Android native) also exists but is not integrated with Flutter app.
- **Media playback library**: PRESENT
  - Using `video_player` with Chewie wrapper in `player_screen.dart`.
- **Subtitle parsing**: PRESENT
  - Using `subtitle` package plus `SubtitleUtils` for `.srt`.
- **Filesystem access**: PRESENT
  - Using `file_picker` and `dart:io`.
- **Window always-on-top**: PRESENT
  - Using `window_manager`.

### 4) Browser Extension
- **WebExtension (manifest.json, content script, UI)**: MISSING
  - No `manifest.json` or extension folder found. No injection/communication code present.

### 5) Development Stages Coverage
- **Stage 1 (UI + basic playback)**: PARTIAL/GOOD
  - Core screens and playback exist. Progress via Chewie. Needs explicit next/prev track mechanics if desired.
- **Stage 2 (advanced features)**: PARTIAL
  - Seek presets incomplete. Speed control complete. Subtitle pipeline present but not integrated into playback rendering and has a settings type bug.
- **Stage 3 (system integration)**: PARTIAL/GOOD
  - Folder access and always-on-top complete.
- **Stage 4 (browser extension)**: MISSING
- **Stage 5 (polish + packaging)**: NOT EVALUATED

### Detected Gaps and Fix Suggestions
1) Implement 1-minute and 10-minute seek controls in `player_screen.dart` (UI + handlers).
2) Wire `SubtitleService` into `PlayerScreen` to render actual `.srt` text:
   - Load on media open if `mediaFile.subtitlePath != null`.
   - On `VideoPlayerController` position updates (e.g., via a periodic timer or listener), fetch subtitle text with playback speed and display in an overlay.
3) Fix `AppSettings.subtitleColor` type mismatch:
   - Change from `String` to `Color` and update persistence to store int value; or
   - Keep as `String` but convert in UI to `Color` consistently. Current code mixes types and will not compile.
4) Ensure subtitle customization (font family/size/color/background) is applied to the on-screen text when wired to `SubtitleService`.
5) Add explicit next/previous file navigation (based on recent list or folder list) if required by "giao diện truyền thống".
6) Add WebExtension project (manifest v3, content script to detect HTML5 video and inject controls, messaging bridge if interaction with desktop app is needed).

### Quick Compliance Matrix
- **Formats**: PARTIAL
- **Basic controls**: PARTIAL
- **Progress bar**: PARTIAL (Chewie default)
- **Seek 10s/1m/10m**: PARTIAL (10s & 30s only)
- **Speed slider 0.1–10x**: COMPLETE
- **Speed presets**: COMPLETE
- **Speed +/- 0.1 / 0.25**: COMPLETE
- **.srt support**: PARTIAL (parse ok, render not wired)
- **Subtitle customization**: PARTIAL (UI ok; apply + type fix needed)
- **Sub speed sync**: PARTIAL (service supports; UI not wired)
- **Open from folder**: COMPLETE
- **Always-on-top**: COMPLETE
- **Browser extension**: MISSING

Last updated: automated audit.

