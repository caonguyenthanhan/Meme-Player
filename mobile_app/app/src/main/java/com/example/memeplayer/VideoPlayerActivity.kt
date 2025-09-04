package com.example.memeplayer

import android.net.Uri
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.ui.PlayerView
import android.os.Handler
import android.os.Looper
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContracts
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.Locale
import android.view.View
import android.content.pm.ActivityInfo
import android.view.GestureDetector
import android.view.MotionEvent
import android.media.AudioManager
import android.provider.Settings
import android.app.PictureInPictureParams
import android.util.Rational

class VideoPlayerActivity : AppCompatActivity() {
    private var player: ExoPlayer? = null
    private val uiHandler = Handler(Looper.getMainLooper())
    private var subtitleMap: List<Triple<Long, Long, String>> = emptyList()
    private var currentSubtitleIndex: Int = -1
    private var speed: Float = 1.0f
    private var subtitlesEnabled: Boolean = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_video_player)

        val data: Uri? = intent?.data
        if (data == null) {
            Toast.makeText(this, "Không có tệp để phát", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        val playerView = findViewById<PlayerView>(R.id.player_view)
        player = ExoPlayer.Builder(this).build().also { exoPlayer ->
            playerView.player = exoPlayer
            val item = MediaItem.fromUri(data)
            exoPlayer.setMediaItem(item)
            exoPlayer.prepare()
            exoPlayer.playWhenReady = true
        }

        // Controls
        val btnPlayPause = findViewById<ImageButton>(R.id.btn_play_pause)
        val btnBack10s = findViewById<ImageButton>(R.id.btn_seek_back_10s)
        val btnBack1m = findViewById<ImageButton>(R.id.btn_seek_back_1m)
        val btnBack10m = findViewById<ImageButton>(R.id.btn_seek_back_10m)
        val btnFwd10s = findViewById<ImageButton>(R.id.btn_seek_forward_10s)
        val btnFwd1m = findViewById<ImageButton>(R.id.btn_seek_forward_1m)
        val btnFwd10m = findViewById<ImageButton>(R.id.btn_seek_forward_10m)
        val speedSeek = findViewById<SeekBar>(R.id.speed_seekbar)
        val txtSpeed = findViewById<TextView>(R.id.txt_speed)
        val btnMinus01 = findViewById<Button>(R.id.btn_minus_01)
        val btnMinus025 = findViewById<Button>(R.id.btn_minus_025)
        val btnPlus01 = findViewById<Button>(R.id.btn_plus_01)
        val btnPlus025 = findViewById<Button>(R.id.btn_plus_025)
        val presetContainer = findViewById<LinearLayout>(R.id.preset_container)
        val subtitleText = findViewById<TextView>(R.id.subtitle_text)
        val btnPickSubtitle = findViewById<Button>(R.id.btn_pick_subtitle)
        val btnRotate = findViewById<ImageButton>(R.id.btn_rotate)
        val btnPip = findViewById<ImageButton>(R.id.btn_pip)
        val controlsContainer = findViewById<View>(R.id.controls_container)
        val timeline = findViewById<SeekBar>(R.id.seek_timeline)
        val txtCurrent = findViewById<TextView>(R.id.txt_current)
        val txtDuration = findViewById<TextView>(R.id.txt_duration)

        // Toggle subtitle enabled via long press on subtitle area
        subtitleText.setOnLongClickListener {
            subtitlesEnabled = !subtitlesEnabled
            if (!subtitlesEnabled) subtitleText.text = ""
            Toast.makeText(this, if (subtitlesEnabled) "Bật phụ đề" else "Tắt phụ đề", Toast.LENGTH_SHORT).show()
            true
        }

        // Play/Pause toggle
        btnPlayPause.setOnClickListener {
            player?.let { p ->
                if (p.isPlaying) { p.pause(); btnPlayPause.setImageResource(android.R.drawable.ic_media_play) }
                else { p.play(); btnPlayPause.setImageResource(android.R.drawable.ic_media_pause) }
            }
        }

        fun seekBy(ms: Long) {
            player?.let { p ->
                val pos = p.currentPosition
                p.seekTo((pos + ms).coerceAtLeast(0))
            }
        }
        btnBack10s.setOnClickListener { seekBy(-10_000) }
        btnBack1m.setOnClickListener { seekBy(-60_000) }
        btnBack10m.setOnClickListener { seekBy(-600_000) }
        btnFwd10s.setOnClickListener { seekBy(10_000) }
        btnFwd1m.setOnClickListener { seekBy(60_000) }
        btnFwd10m.setOnClickListener { seekBy(600_000) }

        fun applySpeed(newSpeed: Float) {
            speed = newSpeed.coerceIn(0.1f, 10.0f)
            player?.setPlaybackSpeed(speed)
            txtSpeed.text = String.format(Locale.US, "%.2fx", speed)
        }
        speedSeek.max = 99
        speedSeek.progress = 9 // 1.0x
        speedSeek.setOnSeekBarChangeListener(object: SeekBar.OnSeekBarChangeListener{
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                val value = 0.1f + progress * 0.1f
                applySpeed(value)
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        btnMinus01.setOnClickListener { applySpeed(speed - 0.1f) }
        btnMinus025.setOnClickListener { applySpeed(speed - 0.25f) }
        btnPlus01.setOnClickListener { applySpeed(speed + 0.1f) }
        btnPlus025.setOnClickListener { applySpeed(speed + 0.25f) }

        val presets = listOf(0.1f, 0.5f, 0.75f, 1f, 1.5f, 1.75f, 2f, 2.5f, 3f, 5f, 10f)
        presets.forEach { s ->
            val b = Button(this)
            b.text = "${s}x"
            b.setOnClickListener { applySpeed(s) }
            presetContainer.addView(b)
        }

        // Subtitle - simple SRT picker
        val pickSubtitle = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
            if (uri != null) {
                contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                subtitleMap = loadSrt(uri)
                Toast.makeText(this, "Đã tải phụ đề", Toast.LENGTH_SHORT).show()
            }
        }
        btnPickSubtitle.setOnClickListener {
            pickSubtitle.launch(arrayOf("text/plain", "application/x-subrip"))
        }

        // Toggle custom controls on tap
        playerView.setOnClickListener {
            controlsContainer.visibility = if (controlsContainer.visibility == View.VISIBLE) View.GONE else View.VISIBLE
        }

        // Gesture handling (no overrides dependency)
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val gestureDetector = GestureDetector(this, object : GestureDetector.SimpleOnGestureListener() {
            override fun onDoubleTap(e: MotionEvent): Boolean {
                val isLeft = e.x < playerView.width / 2
                if (isLeft) seekBy(-10_000) else seekBy(10_000)
                return true
            }
        })

        var startX = 0f
        var startY = 0f
        var longPressActive = false
        var longPressDir = 0
        val longPressRunnable = object : Runnable {
            override fun run() {
                if (longPressActive) {
                    seekBy((longPressDir * 3_000).toLong())
                    uiHandler.postDelayed(this, 150)
                }
            }
        }

        playerView.setOnTouchListener { _, event ->
            // also pass to detector for double-tap
            gestureDetector.onTouchEvent(event)
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    startX = event.x
                    startY = event.y
                    longPressActive = true
                    longPressDir = if (startX < playerView.width / 2) -1 else 1
                    uiHandler.postDelayed(longPressRunnable, 600)
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.x - startX
                    val dy = event.y - startY
                    // cancel long press if user moves significantly
                    if (Math.abs(dx) > 20 || Math.abs(dy) > 20) {
                        longPressActive = false
                    }
                    if (Math.abs(dx) > Math.abs(dy)) {
                        // horizontal seek
                        seekBy((dx / playerView.width * 120_000).toLong())
                    } else {
                        val isLeft = startX < playerView.width / 2
                        if (isLeft) {
                            // brightness via window attributes (does not require write settings)
                            val lp = window.attributes
                            val cur = if (lp.screenBrightness in 0f..1f) lp.screenBrightness else 0.5f
                            val newVal = (cur - dy / playerView.height).coerceIn(0.05f, 1.0f)
                            lp.screenBrightness = newVal
                            window.attributes = lp
                        } else {
                            // volume
                            val cur = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                            val newVal = (cur - dy / playerView.height * maxVolume).toInt().coerceIn(0, maxVolume)
                            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVal, 0)
                        }
                    }
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    longPressActive = false
                }
            }
            true
        }

        // Render loop for subtitles
        fun tick() {
            val p = player ?: return
            val positionMs = (p.currentPosition / speed).toLong() // adjust by speed
            val idx = subtitleMap.indexOfFirst { positionMs in it.first..it.second }
            if (idx != currentSubtitleIndex) {
                currentSubtitleIndex = idx
                val text = if (idx >= 0 && subtitlesEnabled) subtitleMap[idx].third else ""
                subtitleText.text = text
                subtitleText.visibility = if (text.isEmpty()) View.GONE else View.VISIBLE
            }
            uiHandler.postDelayed({ tick() }, 200)
        }
        tick()

        // Rotate button: toggle portrait/landscape
        btnRotate.setOnClickListener {
            requestedOrientation = if (resources.configuration.orientation == android.content.res.Configuration.ORIENTATION_PORTRAIT)
                ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE else ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        }

        // Picture-in-Picture button and keyboard shortcut
        fun enterPip() {
            val aspect = if (playerView.width > 0 && playerView.height > 0)
                Rational(playerView.width, playerView.height) else Rational(16,9)
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(aspect)
                .build()
            enterPictureInPictureMode(params)
        }
        btnPip.setOnClickListener { enterPip() }

        // Keyboard shortcut: P to PiP (for devices with keyboard)
        controlsContainer.isFocusableInTouchMode = true
        controlsContainer.requestFocus()
        controlsContainer.setOnKeyListener { _, keyCode, event ->
            if (event.action == android.view.KeyEvent.ACTION_DOWN && keyCode == android.view.KeyEvent.KEYCODE_P) {
                enterPip(); true
            } else false
        }

        // Timeline update loop
        fun format(ms: Long): String {
            val totalSec = (ms / 1000).toInt()
            val m = totalSec / 60
            val s = totalSec % 60
            return String.format(Locale.US, "%02d:%02d", m, s)
        }
        uiHandler.post(object: Runnable {
            override fun run() {
                player?.let { p ->
                    val dur = if (p.duration > 0) p.duration else 0
                    val pos = p.currentPosition
                    txtDuration.text = format(dur)
                    txtCurrent.text = format(pos)
                    if (dur > 0) {
                        timeline.progress = ((pos.toDouble() / dur) * 1000).toInt()
                    }
                }
                uiHandler.postDelayed(this, 250)
            }
        })

        timeline.setOnSeekBarChangeListener(object: SeekBar.OnSeekBarChangeListener{
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) {
                    player?.let { p ->
                        val dur = if (p.duration > 0) p.duration else 0
                        val newPos = dur * progress / 1000
                        p.seekTo(newPos)
                    }
                }
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) { }
            override fun onStopTrackingTouch(seekBar: SeekBar?) { }
        })

        // Auto hide controls after inactivity
        var lastUserAction = System.currentTimeMillis()
        fun scheduleAutoHide() {
            uiHandler.postDelayed({
                if (System.currentTimeMillis() - lastUserAction > 2500) {
                    controlsContainer.visibility = View.GONE
                }
            }, 3000)
        }
        fun markUserAction() { lastUserAction = System.currentTimeMillis(); controlsContainer.visibility = View.VISIBLE; scheduleAutoHide() }
        controlsContainer.setOnTouchListener { _, _ -> markUserAction(); false }
        playerView.setOnTouchListener { _, event ->
            markUserAction()
            gestureDetector.onTouchEvent(event)
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    startX = event.x
                    startY = event.y
                    longPressActive = true
                    longPressDir = if (startX < playerView.width / 2) -1 else 1
                    uiHandler.postDelayed(longPressRunnable, 600)
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.x - startX
                    val dy = event.y - startY
                    if (Math.abs(dx) > 20 || Math.abs(dy) > 20) {
                        longPressActive = false
                    }
                    if (Math.abs(dx) > Math.abs(dy)) {
                        seekBy((dx / playerView.width * 120_000).toLong())
                    } else {
                        val isLeft = startX < playerView.width / 2
                        if (isLeft) {
                            val lp = window.attributes
                            val cur = if (lp.screenBrightness in 0f..1f) lp.screenBrightness else 0.5f
                            val newVal = (cur - dy / playerView.height).coerceIn(0.05f, 1.0f)
                            lp.screenBrightness = newVal
                            window.attributes = lp
                        } else {
                            val cur = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                            val newVal = (cur - dy / playerView.height * maxVolume).toInt().coerceIn(0, maxVolume)
                            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVal, 0)
                        }
                    }
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> { longPressActive = false }
            }
            true
        }

        // Enter PiP when home pressed or user taps a special gesture - optional: button in future
    }

    override fun onStop() {
        super.onStop()
        player?.release()
        player = null
    }

    private fun loadSrt(uri: android.net.Uri): List<Triple<Long, Long, String>> {
        return try {
            val input = contentResolver.openInputStream(uri) ?: return emptyList()
            val reader = BufferedReader(InputStreamReader(input, "UTF-8"))
            val list = mutableListOf<Triple<Long, Long, String>>()
            var line: String?
            var start: Long = -1
            var end: Long = -1
            val textBuilder = StringBuilder()
            
            fun flush() {
                if (start >= 0 && end >= 0 && textBuilder.isNotEmpty()) {
                    list.add(Triple(start, end, textBuilder.toString().trim()))
                }
                start = -1; end = -1; textBuilder.setLength(0)
            }
            
            while (reader.readLine().also { line = it } != null) {
                val l = line?.trim() ?: continue
                if (l.matches(Regex("^\\d+$"))) continue
                if (l.contains("-->")) {
                    val parts = l.split("-->")
                    if (parts.size == 2) {
                        start = parseSrtTime(parts[0].trim())
                        end = parseSrtTime(parts[1].trim())
                    }
                } else if (l.isEmpty()) {
                    flush()
                } else {
                    if (textBuilder.isNotEmpty()) textBuilder.append('\n')
                    textBuilder.append(l)
                }
            }
            flush()
            reader.close()
            input.close()
            list
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "Lỗi đọc file phụ đề: ${e.message}", Toast.LENGTH_LONG).show()
            emptyList()
        }
    }

    private fun parseSrtTime(s: String): Long {
        return try {
            val parts = s.split(":", ",")
            if (parts.size != 4) return 0L
            
            val h = parts[0].toLong()
            val m = parts[1].toLong()
            val sec = parts[2].toLong()
            val ms = parts[3].toLong()
            ((h*3600 + m*60 + sec)*1000 + ms)
        } catch (e: Exception) {
            e.printStackTrace()
            0L
        }
    }
}


