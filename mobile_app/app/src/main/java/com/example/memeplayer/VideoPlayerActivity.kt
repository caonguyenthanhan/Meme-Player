package com.example.memeplayer

import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import android.widget.AdapterView
import android.widget.EditText
import androidx.appcompat.app.AlertDialog
import android.view.inputmethod.InputMethodManager
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
import android.view.ScaleGestureDetector
import android.media.AudioManager
import android.provider.Settings
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.graphics.drawable.Icon
import android.util.Rational
import android.view.WindowManager
import com.google.android.exoplayer2.Player
import androidx.core.content.ContextCompat

class VideoPlayerActivity : AppCompatActivity() {
    private var player: ExoPlayer? = null
    private lateinit var playerView: PlayerView
    private val uiHandler = Handler(Looper.getMainLooper())
    private var subtitleMap: List<Triple<Long, Long, String>> = emptyList()
    private lateinit var historyService: PlaybackHistoryService
    private lateinit var subtitlePrefsService: SubtitlePreferencesService
    private lateinit var defaultSubtitlePrefsService: DefaultSubtitlePreferencesService
    private var currentVideoUri: Uri? = null
    private var currentVideoName: String = ""
    private var currentSubtitleIndex: Int = -1
    private var speed: Float = 1.0f
    private var subtitlesEnabled: Boolean = true
    
    // Subtitle styling properties
    private var subtitleTextSize: Float = 18f
    private var subtitleTextColor: Int = android.graphics.Color.WHITE
    private var subtitleBackgroundColor: Int = android.graphics.Color.BLACK
    private var subtitleBackgroundOpacity: Float = 0.7f
    private var subtitleFontFamily: String = "default"
    
    // Video zoom properties
    private var videoScaleFactor: Float = 1.0f
    private val minZoom = 0.1f
    private val maxZoom = 5.0f
    private lateinit var scaleGestureDetector: ScaleGestureDetector
    
    // Auto-hide controls properties
    private var autoHideRunnable: Runnable? = null
    private val AUTO_HIDE_DELAY = 5000L // 5 seconds
    
    // PiP mode constants
    companion object {
        private const val ACTION_REWIND = "com.example.memeplayer.REWIND"
        private const val ACTION_PLAY_PAUSE = "com.example.memeplayer.PLAY_PAUSE"
        private const val ACTION_FORWARD = "com.example.memeplayer.FORWARD"
    }
    
    // PiP broadcast receiver
    private val pipReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                ACTION_REWIND -> seekBy(-10_000)
                ACTION_PLAY_PAUSE -> {
                    player?.let { p ->
                        if (p.isPlaying) p.pause() else p.play()
                    }
                }
                ACTION_FORWARD -> seekBy(10_000)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_video_player)
        supportActionBar?.hide()
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val data: Uri? = intent?.data
        if (data == null) {
            Toast.makeText(this, "Không có tệp để phát", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        // Initialize services
        historyService = PlaybackHistoryService(this)
        subtitlePrefsService = SubtitlePreferencesService(this)
        defaultSubtitlePrefsService = DefaultSubtitlePreferencesService(this)
        currentVideoUri = data
        currentVideoName = data.lastPathSegment?.substringAfterLast('/') ?: "Video"
        
        // Load saved subtitle settings for this video
        loadSavedSubtitleSettings()
        
        // Display video title - will sync with controls visibility
        val videoTitle = findViewById<TextView>(R.id.video_title)
        val displayName = currentVideoName.substringBeforeLast('.').replace('_', ' ')
        videoTitle.text = displayName
        
        // Long press on video title to rename
        videoTitle.setOnLongClickListener {
            showRenameDialog()
            true
        }

        initializePlayer(data)

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
        val volumeIndicator = findViewById<LinearLayout>(R.id.volume_indicator)
        val brightnessIndicator = findViewById<LinearLayout>(R.id.brightness_indicator)
        val volumeText = findViewById<TextView>(R.id.volume_text)
        val brightnessText = findViewById<TextView>(R.id.brightness_text)

        // Toggle subtitle enabled via long press on subtitle area
        subtitleText.setOnLongClickListener {
            subtitlesEnabled = !subtitlesEnabled
            if (!subtitlesEnabled) subtitleText.text = ""
            Toast.makeText(this, if (subtitlesEnabled) "Bật phụ đề" else "Tắt phụ đề", Toast.LENGTH_SHORT).show()
            true
        }
        
        // Initialize subtitle position
        updateSubtitlePosition(controlsContainer.visibility == View.VISIBLE)
        
        // Register PiP broadcast receiver
        val filter = IntentFilter().apply {
            addAction(ACTION_REWIND)
            addAction(ACTION_PLAY_PAUSE)
            addAction(ACTION_FORWARD)
        }
        ContextCompat.registerReceiver(this, pipReceiver, filter, ContextCompat.RECEIVER_NOT_EXPORTED)
        
        // Initialize zoom gesture detector
        scaleGestureDetector = ScaleGestureDetector(this, object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
            override fun onScale(detector: ScaleGestureDetector): Boolean {
                videoScaleFactor *= detector.scaleFactor
                videoScaleFactor = videoScaleFactor.coerceIn(minZoom, maxZoom)
                playerView.scaleX = videoScaleFactor
                playerView.scaleY = videoScaleFactor
                return true
            }
        })

        // Play/Pause toggle
        btnPlayPause.setOnClickListener {
            player?.let { p ->
                if (p.isPlaying) {
                    p.pause()
                    btnPlayPause.setImageResource(android.R.drawable.ic_media_play)
                } else {
                    p.play()
                    btnPlayPause.setImageResource(android.R.drawable.ic_media_pause)
                }
            }
            resetAutoHideTimer()
        }


        btnBack10s.setOnClickListener { seekBy(-10_000); resetAutoHideTimer() }
        btnBack1m.setOnClickListener { seekBy(-60_000); resetAutoHideTimer() }
        btnBack10m.setOnClickListener { seekBy(-600_000); resetAutoHideTimer() }
        btnFwd10s.setOnClickListener { seekBy(10_000); resetAutoHideTimer() }
        btnFwd1m.setOnClickListener { seekBy(60_000); resetAutoHideTimer() }
        btnFwd10m.setOnClickListener { seekBy(600_000); resetAutoHideTimer() }

        fun applySpeed(newSpeed: Float) {
            speed = newSpeed.coerceIn(0.1f, 10.0f)
            player?.setPlaybackSpeed(speed)
            txtSpeed.text = String.format(Locale.US, "%.2fx", speed)
            
            // Update seekbar to match the speed
            val seekbarProgress = ((speed - 0.1f) / 0.1f).toInt()
            speedSeek.progress = seekbarProgress
        }
        speedSeek.max = 99
        speedSeek.progress = 9 // 1.0x
        speedSeek.setOnSeekBarChangeListener(object: SeekBar.OnSeekBarChangeListener{
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                val value = 0.1f + progress * 0.1f
                applySpeed(value)
                if (fromUser) resetAutoHideTimer()
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) { resetAutoHideTimer() }
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        btnMinus01.setOnClickListener { applySpeed(speed - 0.1f); resetAutoHideTimer() }
        btnMinus025.setOnClickListener { applySpeed(speed - 0.25f); resetAutoHideTimer() }
        btnPlus01.setOnClickListener { applySpeed(speed + 0.1f); resetAutoHideTimer() }
        btnPlus025.setOnClickListener { applySpeed(speed + 0.25f); resetAutoHideTimer() }

        val presets = listOf(0.1f, 0.5f, 0.75f, 1f, 1.5f, 1.75f, 2f, 2.5f, 3f, 5f, 10f)
        presets.forEach { s ->
            val b = Button(this)
            b.text = "${s}x"
            b.setOnClickListener { 
                applySpeed(s)
                resetAutoHideTimer()
                // Seekbar will be updated automatically by applySpeed function
            }
            presetContainer.addView(b)
        }

        // Subtitle - simple SRT picker
        val pickSubtitle = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
            if (uri != null) {
                contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                subtitleMap = loadSrt(uri)
                currentSubtitleUri = uri
                saveCurrentSubtitleSettings()
                Toast.makeText(this, "Đã tải phụ đề", Toast.LENGTH_SHORT).show()
            }
        }
        btnPickSubtitle.setOnClickListener {
            pickSubtitle.launch(arrayOf("text/plain", "application/x-subrip"))
            resetAutoHideTimer()
        }
        
        // Edit subtitle button
        val btnEditSubtitle = findViewById<Button>(R.id.btn_edit_subtitle)
        btnEditSubtitle.setOnClickListener {
            showSubtitleEditor()
            resetAutoHideTimer()
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
            
            override fun onSingleTapConfirmed(e: MotionEvent): Boolean {
                val controlsContainer = findViewById<View>(R.id.controls_container)
                if (controlsContainer.visibility == View.VISIBLE) {
                    hideControls()
                } else {
                    showControls() // Show with timer for tap gesture
                }
                return true
            }
        })

        var startX = 0f
        var startY = 0f
        var longPressActive = false
        var longPressDir = 0
        var isSwipeGesture = false
        val longPressRunnable = object : Runnable {
            override fun run() {
                if (longPressActive) {
                    seekBy((longPressDir * 3_000).toLong())
                    uiHandler.postDelayed(this, 150)
                }
            }
        }

        playerView.setOnTouchListener { _, event ->
            // Handle touch interaction for controls
            if (event.actionMasked == MotionEvent.ACTION_DOWN) {
                val controlsContainer = findViewById<View>(R.id.controls_container)
                if (controlsContainer.visibility == View.VISIBLE) {
                    // Controls already visible - just reset timer
                    resetAutoHideTimer()
                } else {
                    // Controls hidden - show them without starting timer yet
                    showControlsWithoutTimer()
                }
            }
            
            // Handle zoom gesture first
            if (scaleGestureDetector.onTouchEvent(event)) {
                return@setOnTouchListener true
            }
            
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    startX = event.x
                    startY = event.y
                    longPressActive = true
                    longPressDir = if (startX < playerView.width / 2) -1 else 1
                    isSwipeGesture = false
                    uiHandler.postDelayed(longPressRunnable, 600)
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.x - startX
                    val dy = event.y - startY
                    
                    // Check if this is a swipe gesture
                    if (Math.abs(dx) > 30 || Math.abs(dy) > 30) {
                        isSwipeGesture = true
                        longPressActive = false
                        
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
                                
                                // Show brightness indicator
                                val percentage = (newVal * 100).toInt()
                                brightnessText.text = "$percentage%"
                                brightnessIndicator.visibility = View.VISIBLE
                                
                                // Auto-hide after 1 second
                                uiHandler.removeCallbacksAndMessages("brightness")
                                uiHandler.postDelayed({
                                    brightnessIndicator.visibility = View.GONE
                                }, 1000)
                            } else {
                                // volume
                                val cur = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                                val newVal = (cur - dy / playerView.height * maxVolume).toInt().coerceIn(0, maxVolume)
                                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVal, 0)
                                
                                // Show volume indicator
                                val percentage = (newVal * 100 / maxVolume)
                                volumeText.text = "$percentage%"
                                volumeIndicator.visibility = View.VISIBLE
                                
                                // Auto-hide after 1 second
                                uiHandler.removeCallbacksAndMessages("volume")
                                uiHandler.postDelayed({
                                    volumeIndicator.visibility = View.GONE
                                }, 1000)
                            }
                        }
                    }
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    longPressActive = false
                }
            }
            
            // Pass to gesture detector only if not a swipe gesture
            if (!isSwipeGesture) {
                gestureDetector.onTouchEvent(event)
            }
            
            true
        }
        
        // PiP button click handler
        btnPip.setOnClickListener {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                setupPipMode()
                enterPictureInPictureMode()
            } else {
                Toast.makeText(this, "PiP mode không được hỗ trợ trên thiết bị này", Toast.LENGTH_SHORT).show()
            }
            resetAutoHideTimer()
        }
        
        // Rotate button click handler
        btnRotate.setOnClickListener {
            requestedOrientation = when (requestedOrientation) {
                ActivityInfo.SCREEN_ORIENTATION_PORTRAIT -> ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
                ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE -> ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE
                ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE -> ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT
                else -> ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            }
            resetAutoHideTimer()
        }
        
        val btnHideControls = findViewById<ImageButton>(R.id.btn_hide_controls)
        btnHideControls.setOnClickListener {
            hideControls()
        }

        // Render loop for subtitles
        fun tick() {
            val p = player ?: return
            val positionMs = p.currentPosition // ExoPlayer already handles speed internally
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
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                val aspect = if (playerView.width > 0 && playerView.height > 0)
                    Rational(playerView.width, playerView.height) else Rational(16,9)
                val params = PictureInPictureParams.Builder()
                    .setAspectRatio(aspect)
                    .build()
                enterPictureInPictureMode(params)
            }
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
                    videoTitle.visibility = View.GONE
                }
            }, 3000)
        }
        fun markUserAction() { 
            lastUserAction = System.currentTimeMillis()
            controlsContainer.visibility = View.VISIBLE
            videoTitle.visibility = View.VISIBLE
            scheduleAutoHide() 
        }
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
                            
                            // Show brightness indicator
                            val percentage = (newVal * 100).toInt()
                            brightnessText.text = "$percentage%"
                            brightnessIndicator.visibility = View.VISIBLE
                            
                            // Auto-hide after 1 second
                            uiHandler.removeCallbacksAndMessages("brightness")
                            uiHandler.postDelayed({
                                brightnessIndicator.visibility = View.GONE
                            }, 1000)
                        } else {
                            val cur = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                            val newVal = (cur - dy / playerView.height * maxVolume).toInt().coerceIn(0, maxVolume)
                            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVal, 0)
                            
                            // Show volume indicator
                            val percentage = (newVal * 100 / maxVolume)
                            volumeText.text = "$percentage%"
                            volumeIndicator.visibility = View.VISIBLE
                            
                            // Auto-hide after 1 second
                            uiHandler.removeCallbacksAndMessages("volume")
                            uiHandler.postDelayed({
                                volumeIndicator.visibility = View.GONE
                            }, 1000)
                        }
                    }
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> { longPressActive = false }
            }
            true
        }

        // Enter PiP when home pressed or user taps a special gesture - optional: button in future
        
        // Show controls initially when video starts
        showControls()
        
        // Setup long press for video title to rename
        videoTitle.setOnLongClickListener {
            showRenameDialog()
            true
        }
    }

    private fun seekBy(ms: Long) {
        player?.let { p ->
            val pos = p.currentPosition
            p.seekTo((pos + ms).coerceAtLeast(0))
        }
    }
    
    private fun toggleControlsVisibility() {
        val controlsContainer = findViewById<View>(R.id.controls_container)
        val videoTitle = findViewById<TextView>(R.id.video_title)
        
        if (controlsContainer.visibility == View.VISIBLE) {
            hideControls()
        } else {
            showControls()
        }
    }
    
    private fun showControls() {
        val controlsContainer = findViewById<View>(R.id.controls_container)
        val videoTitle = findViewById<TextView>(R.id.video_title)
        
        controlsContainer.visibility = View.VISIBLE
        videoTitle.visibility = View.VISIBLE
        updateSubtitlePosition(true)
        scheduleAutoHide()
    }
    
    private fun showControlsWithoutTimer() {
        val controlsContainer = findViewById<View>(R.id.controls_container)
        val videoTitle = findViewById<TextView>(R.id.video_title)
        
        controlsContainer.visibility = View.VISIBLE
        videoTitle.visibility = View.VISIBLE
        updateSubtitlePosition(true)
        // Don't schedule auto-hide yet - wait for user interaction
    }
    
    private fun hideControls() {
        val controlsContainer = findViewById<View>(R.id.controls_container)
        val videoTitle = findViewById<TextView>(R.id.video_title)
        
        controlsContainer.visibility = View.GONE
        videoTitle.visibility = View.GONE
        updateSubtitlePosition(false)
        cancelAutoHide()
    }
    
    private fun scheduleAutoHide() {
        cancelAutoHide()
        autoHideRunnable = Runnable {
            hideControls()
        }
        uiHandler.postDelayed(autoHideRunnable!!, AUTO_HIDE_DELAY)
    }
    
    private fun cancelAutoHide() {
        autoHideRunnable?.let {
            uiHandler.removeCallbacks(it)
            autoHideRunnable = null
        }
    }
    
    private fun resetAutoHideTimer() {
        val controlsContainer = findViewById<View>(R.id.controls_container)
        if (controlsContainer.visibility == View.VISIBLE) {
            scheduleAutoHide()
        }
    }
    
    private fun showRenameDialog() {
        val builder = AlertDialog.Builder(this)
        builder.setTitle("Đổi tên video")
        
        val input = EditText(this)
        input.setText(currentVideoName)
        input.selectAll()
        builder.setView(input)
        
        builder.setPositiveButton("OK") { _, _ ->
            val newName = input.text.toString().trim()
            if (newName.isNotEmpty() && newName != currentVideoName) {
                currentVideoName = newName
                findViewById<TextView>(R.id.video_title).text = newName
                resetAutoHideTimer()
            }
        }
        
        builder.setNegativeButton("Hủy") { dialog, _ ->
            dialog.cancel()
        }
        
        val dialog = builder.create()
        dialog.show()
        
        // Focus on input and show keyboard
        input.requestFocus()
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(input, InputMethodManager.SHOW_IMPLICIT)
    }
    
    private fun initializePlayer(videoUri: Uri) {
        playerView = findViewById<PlayerView>(R.id.player_view)
        player = ExoPlayer.Builder(this).build().also { exoPlayer ->
            playerView.player = exoPlayer
            val item = MediaItem.fromUri(videoUri)
            exoPlayer.setMediaItem(item)
            exoPlayer.prepare()
            
            // Restore playback position from history
            val savedPosition = historyService.getPlaybackPosition(videoUri)
            if (savedPosition > 0) {
                exoPlayer.seekTo(savedPosition)
            }
            
            exoPlayer.playWhenReady = true
            exoPlayer.play()
            
            // Add listener for video completion and play state changes
            exoPlayer.addListener(object : Player.Listener {
                override fun onPlaybackStateChanged(playbackState: Int) {
                    if (playbackState == Player.STATE_ENDED) {
                        showVideoEndDialog()
                    }
                }
                
                override fun onIsPlayingChanged(isPlaying: Boolean) {
                    val btnPlayPause = findViewById<ImageButton>(R.id.btn_play_pause)
                    if (isPlaying) {
                        btnPlayPause.setImageResource(android.R.drawable.ic_media_pause)
                    } else {
                        btnPlayPause.setImageResource(android.R.drawable.ic_media_play)
                    }
                }
            })
        }
    }

    override fun onPause() {
        super.onPause()
        
        // Save playback position to history when pausing
        currentVideoUri?.let { uri ->
            player?.let { player ->
                val currentPosition = player.currentPosition
                val duration = player.duration
                if (duration > 0) {
                    historyService.savePlaybackPosition(uri, currentVideoName, currentPosition, duration)
                }
            }
        }
    }
    
    override fun onResume() {
        super.onResume()
        
        // Restore player state if it was released
        if (player == null && currentVideoUri != null) {
            initializePlayer(currentVideoUri!!)
        }
        
        // Show controls when resuming the activity
        showControls()
    }

    override fun onStop() {
        super.onStop()
        
        // Save playback position to history
        currentVideoUri?.let { uri ->
            player?.let { player ->
                val currentPosition = player.currentPosition
                val duration = player.duration
                if (duration > 0) {
                    historyService.savePlaybackPosition(uri, currentVideoName, currentPosition, duration)
                }
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        saveCurrentSubtitleSettings()
        unregisterReceiver(pipReceiver)
        player?.release()
        player = null
    }
    
    private fun showVideoEndDialog() {
        AlertDialog.Builder(this)
            .setTitle("Video đã kết thúc")
            .setMessage("Bạn muốn làm gì tiếp theo?")
            .setPositiveButton("Phát lại") { _, _ ->
                player?.seekTo(0)
                player?.play()
            }
            .setNeutralButton("Video tiếp theo") { _, _ ->
                // TODO: Implement next video functionality
                Toast.makeText(this, "Chức năng video tiếp theo sẽ được thêm sau", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Thoát") { _, _ ->
                finish()
            }
            .setCancelable(false)
            .show()
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
    
    private fun showSubtitleEditor() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_subtitle_editor, null)
        
        // Get UI elements
        val seekTextSize = dialogView.findViewById<SeekBar>(R.id.seekbar_font_size)
        val txtTextSizeValue = dialogView.findViewById<TextView>(R.id.txt_font_size)
        val seekBackgroundOpacity = dialogView.findViewById<SeekBar>(R.id.seekbar_bg_opacity)
        val txtOpacityValue = dialogView.findViewById<TextView>(R.id.txt_bg_opacity)
        val spinnerFontFamily = dialogView.findViewById<Spinner>(R.id.spinner_font_family)
        val txtPreview = dialogView.findViewById<TextView>(R.id.txt_preview)
        
        // Color buttons
        val btnColorWhite = dialogView.findViewById<Button>(R.id.btn_color_white)
        val btnColorYellow = dialogView.findViewById<Button>(R.id.btn_color_yellow)
        val btnColorRed = dialogView.findViewById<Button>(R.id.btn_color_red)
        val btnColorGreen = dialogView.findViewById<Button>(R.id.btn_color_green)
        val btnColorBlue = dialogView.findViewById<Button>(R.id.btn_color_blue)
        val btnColorPicker = dialogView.findViewById<Button>(R.id.btn_color_picker)
        
        // Background color buttons
        val btnBgTransparent = dialogView.findViewById<Button>(R.id.btn_bg_transparent)
        val btnBgBlack = dialogView.findViewById<Button>(R.id.btn_bg_black)
        val btnBgGray = dialogView.findViewById<Button>(R.id.btn_bg_gray)
        val btnBgWhite = dialogView.findViewById<Button>(R.id.btn_bg_white)
        val btnBgColorPicker = dialogView.findViewById<Button>(R.id.btn_bg_color_picker)
        
        // Preview variables (separate from actual subtitle settings)
        var previewTextSize = subtitleTextSize
        var previewTextColor = subtitleTextColor
        var previewBackgroundColor = subtitleBackgroundColor
        var previewBackgroundOpacity = subtitleBackgroundOpacity
        var previewFontFamily = subtitleFontFamily
        
        // Function to update preview only
        fun updatePreview() {
            txtPreview.textSize = previewTextSize
            txtPreview.setTextColor(previewTextColor)
            
            // Handle transparent background properly
            if (previewBackgroundColor == android.graphics.Color.TRANSPARENT) {
                txtPreview.setBackgroundColor(android.graphics.Color.TRANSPARENT)
            } else {
                val backgroundColor = android.graphics.Color.argb(
                    (previewBackgroundOpacity * 255).toInt(),
                    android.graphics.Color.red(previewBackgroundColor),
                    android.graphics.Color.green(previewBackgroundColor),
                    android.graphics.Color.blue(previewBackgroundColor)
                )
                txtPreview.setBackgroundColor(backgroundColor)
            }
            
            // Apply font family
            val typeface = when (previewFontFamily) {
                "serif" -> android.graphics.Typeface.SERIF
                "sans-serif" -> android.graphics.Typeface.SANS_SERIF
                "monospace" -> android.graphics.Typeface.MONOSPACE
                else -> android.graphics.Typeface.DEFAULT
            }
            txtPreview.typeface = typeface
        }
        
        // Set initial values
        seekTextSize.progress = (subtitleTextSize - 10f).toInt()
        txtTextSizeValue.text = "${subtitleTextSize.toInt()}sp"
        seekBackgroundOpacity.progress = (subtitleBackgroundOpacity * 100).toInt()
        txtOpacityValue.text = "${(subtitleBackgroundOpacity * 100).toInt()}%"
        
        // Setup font family spinner with system fonts
        val fontFamilies = arrayOf("Default", "Serif", "Sans Serif", "Monospace")
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, fontFamilies)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        spinnerFontFamily.adapter = adapter
        
        // Set initial font selection
        val initialFontIndex = when (subtitleFontFamily) {
            "serif" -> 1
            "sans-serif" -> 2
            "monospace" -> 3
            else -> 0
        }
        spinnerFontFamily.setSelection(initialFontIndex)
        
        // Set preview text to show current subtitle settings
        txtPreview.text = "Đây là phụ đề mẫu"
        
        // Initialize preview variables with current settings
        previewTextSize = subtitleTextSize
        previewTextColor = subtitleTextColor
        previewBackgroundColor = subtitleBackgroundColor
        previewBackgroundOpacity = subtitleBackgroundOpacity
        previewFontFamily = subtitleFontFamily
        
        // Initial preview update with current subtitle settings
        updatePreview()
        
        // Setup seekbar listeners - only update preview
        seekTextSize.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                previewTextSize = (progress + 10).toFloat()
                txtTextSizeValue.text = "${previewTextSize.toInt()}sp"
                updatePreview()
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        seekBackgroundOpacity.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                previewBackgroundOpacity = progress / 100f
                txtOpacityValue.text = "${progress}%"
                updatePreview()
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        // Setup font family spinner listener
        spinnerFontFamily.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                previewFontFamily = when (position) {
                    1 -> "serif"
                    2 -> "sans-serif"
                    3 -> "monospace"
                    else -> "default"
                }
                updatePreview()
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
        
        // Setup color button listeners - only update preview
        btnColorWhite.setOnClickListener {
            previewTextColor = android.graphics.Color.WHITE
            updatePreview()
        }
        btnColorYellow.setOnClickListener {
            previewTextColor = android.graphics.Color.YELLOW
            updatePreview()
        }
        btnColorRed.setOnClickListener {
            previewTextColor = android.graphics.Color.RED
            updatePreview()
        }
        btnColorGreen.setOnClickListener {
            previewTextColor = android.graphics.Color.GREEN
            updatePreview()
        }
        btnColorBlue.setOnClickListener {
            previewTextColor = android.graphics.Color.BLUE
            updatePreview()
        }
        
        // Setup background color button listeners - only update preview
        btnBgTransparent.setOnClickListener {
            previewBackgroundColor = android.graphics.Color.TRANSPARENT
            updatePreview()
        }
        btnBgBlack.setOnClickListener {
            previewBackgroundColor = android.graphics.Color.BLACK
            updatePreview()
        }
        btnBgGray.setOnClickListener {
            previewBackgroundColor = android.graphics.Color.GRAY
            updatePreview()
        }
        btnBgWhite.setOnClickListener {
            previewBackgroundColor = android.graphics.Color.WHITE
            updatePreview()
        }
        
        // Color picker button listeners
        btnColorPicker.setOnClickListener {
            showColorPicker("Chọn màu chữ") { color ->
                previewTextColor = color
                updatePreview()
            }
        }
        
        btnBgColorPicker.setOnClickListener {
            showColorPicker("Chọn màu nền") { color ->
                previewBackgroundColor = color
                updatePreview()
            }
        }
        
        // Create and show dialog
        val dialog = AlertDialog.Builder(this)
            .setTitle("Chỉnh sửa phụ đề")
            .setView(dialogView)
            .setPositiveButton("Áp dụng") { _, _ ->
                // Apply preview settings to actual subtitle settings
                subtitleTextSize = previewTextSize
                subtitleTextColor = previewTextColor
                subtitleBackgroundColor = previewBackgroundColor
                subtitleBackgroundOpacity = previewBackgroundOpacity
                subtitleFontFamily = previewFontFamily
                updateSubtitleStyle()
                saveCurrentSubtitleSettings()
                Toast.makeText(this, "Đã áp dụng cài đặt phụ đề", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton("Hủy", null)
            .create()
        
        dialog.show()
    }
    
    private fun updateSubtitleStyle() {
        val subtitleText = findViewById<TextView>(R.id.subtitle_text)
        subtitleText.textSize = subtitleTextSize
        subtitleText.setTextColor(subtitleTextColor)
        
        // Apply background with opacity
        val backgroundColor = android.graphics.Color.argb(
            (subtitleBackgroundOpacity * 255).toInt(),
            android.graphics.Color.red(subtitleBackgroundColor),
            android.graphics.Color.green(subtitleBackgroundColor),
            android.graphics.Color.blue(subtitleBackgroundColor)
        )
        subtitleText.setBackgroundColor(backgroundColor)
    }
    
    private fun updateSubtitlePosition(controlsVisible: Boolean) {
        val subtitleText = findViewById<TextView>(R.id.subtitle_text)
        val layoutParams = subtitleText.layoutParams as android.widget.FrameLayout.LayoutParams
        if (controlsVisible) {
            // Controls visible - position subtitle well above controls
            // Increase margin to ensure subtitle is clearly visible above controls
            layoutParams.bottomMargin = 300 // Increased margin to avoid controls overlap
        } else {
            // Controls hidden - position subtitle at bottom with small margin
            layoutParams.bottomMargin = 80
        }
        subtitleText.layoutParams = layoutParams
    }
    
    private fun setupPipMode() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val actions = mutableListOf<RemoteAction>()
            
            // Rewind action
            val rewindIntent = Intent(ACTION_REWIND)
            val rewindPendingIntent = PendingIntent.getBroadcast(this, 0, rewindIntent, PendingIntent.FLAG_IMMUTABLE)
            val rewindIcon = Icon.createWithResource(this, android.R.drawable.ic_media_rew)
            actions.add(RemoteAction(rewindIcon, "Tua lùi", "Tua lùi 10 giây", rewindPendingIntent))
            
            // Play/Pause action
            val playPauseIntent = Intent(ACTION_PLAY_PAUSE)
            val playPausePendingIntent = PendingIntent.getBroadcast(this, 1, playPauseIntent, PendingIntent.FLAG_IMMUTABLE)
            val playPauseIcon = Icon.createWithResource(this, 
                if (player?.isPlaying == true) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play)
            actions.add(RemoteAction(playPauseIcon, "Phát/Tạm dừng", "Phát/Tạm dừng video", playPausePendingIntent))
            
            // Forward action
            val forwardIntent = Intent(ACTION_FORWARD)
            val forwardPendingIntent = PendingIntent.getBroadcast(this, 2, forwardIntent, PendingIntent.FLAG_IMMUTABLE)
            val forwardIcon = Icon.createWithResource(this, android.R.drawable.ic_media_ff)
            actions.add(RemoteAction(forwardIcon, "Tua tới", "Tua tới 10 giây", forwardPendingIntent))
            
            val params = PictureInPictureParams.Builder()
                .setActions(actions)
                .setAspectRatio(Rational(16, 9))
                .build()
            setPictureInPictureParams(params)
        }
    }
    
    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            if (isInPictureInPictureMode) {
                // Hide all UI elements in PiP mode
                findViewById<View>(R.id.controls_container).visibility = View.GONE
                findViewById<TextView>(R.id.video_title).visibility = View.GONE
                setupPipMode()
            } else {
                // Show UI elements when exiting PiP mode
                findViewById<View>(R.id.controls_container).visibility = View.VISIBLE
                findViewById<TextView>(R.id.video_title).visibility = View.VISIBLE
            }
        }
    }
    
    private fun loadSavedSubtitleSettings() {
        currentVideoUri?.let { uri ->
            if (subtitlePrefsService.hasSubtitleSettings(uri)) {
                val settings = subtitlePrefsService.getSubtitleSettings(uri)
                
                // Apply saved settings
                subtitleTextSize = settings.fontSize
                subtitleTextColor = settings.textColor
                subtitleBackgroundColor = settings.backgroundColor
                subtitleBackgroundOpacity = settings.opacity
                subtitleFontFamily = settings.fontStyle
                subtitlesEnabled = settings.isEnabled
                
                // Load saved subtitle file if exists
                settings.subtitlePath?.let { path ->
                    try {
                        val uri = Uri.parse(path)
                        subtitleMap = loadSrt(uri)
                        currentSubtitleUri = uri
                        Toast.makeText(this, "Đã tải phụ đề đã lưu", Toast.LENGTH_SHORT).show()
                    } catch (e: Exception) {
                        Toast.makeText(this, "Không thể tải phụ đề đã lưu", Toast.LENGTH_SHORT).show()
                    }
                }
                
                // Update UI with loaded settings
                updateSubtitleStyle()
            } else {
                // Load default subtitle settings if no specific settings for this video
                val defaultSettings = defaultSubtitlePrefsService.getDefaultSettings()
                if (defaultSettings.enabled) {
                    subtitleTextSize = defaultSettings.fontSize
                    subtitleTextColor = defaultSettings.textColor
                    subtitleBackgroundColor = defaultSettings.backgroundColor
                    subtitleBackgroundOpacity = defaultSettings.backgroundOpacity
                    subtitleFontFamily = defaultSettings.fontFamily
                    subtitlesEnabled = true
                    
                    // Update UI with default settings
                    updateSubtitleStyle()
                }
            }
        }
    }
    
    private var currentSubtitleUri: Uri? = null
    
    private fun saveCurrentSubtitleSettings() {
        currentVideoUri?.let { uri ->
            val settings = SubtitleSettings(
                subtitlePath = currentSubtitleUri?.toString(),
                fontSize = subtitleTextSize,
                textColor = subtitleTextColor,
                backgroundColor = subtitleBackgroundColor,
                fontStyle = subtitleFontFamily,
                opacity = subtitleBackgroundOpacity,
                isEnabled = subtitlesEnabled
            )
            subtitlePrefsService.saveSubtitleSettings(uri, settings)
        }
    }
    
    private fun showColorPicker(title: String, onColorSelected: (Int) -> Unit) {
        val colors = arrayOf(
            android.graphics.Color.WHITE,
            android.graphics.Color.BLACK,
            android.graphics.Color.RED,
            android.graphics.Color.GREEN,
            android.graphics.Color.BLUE,
            android.graphics.Color.YELLOW,
            android.graphics.Color.CYAN,
            android.graphics.Color.MAGENTA,
            android.graphics.Color.GRAY,
            android.graphics.Color.LTGRAY,
            android.graphics.Color.DKGRAY,
            android.graphics.Color.parseColor("#FF6600"), // Orange
            android.graphics.Color.parseColor("#9900CC"), // Purple
            android.graphics.Color.parseColor("#FF1493"), // Deep Pink
            android.graphics.Color.parseColor("#00FF7F"), // Spring Green
            android.graphics.Color.parseColor("#FFD700")  // Gold
        )
        
        val colorNames = arrayOf(
            "Trắng", "Đen", "Đỏ", "Xanh lá", "Xanh dương", "Vàng",
            "Xanh lơ", "Tím hồng", "Xám", "Xám nhạt", "Xám đậm",
            "Cam", "Tím", "Hồng đậm", "Xanh lá nhạt", "Vàng kim"
        )
        
        AlertDialog.Builder(this)
            .setTitle(title)
            .setItems(colorNames) { _, which ->
                onColorSelected(colors[which])
            }
            .setNegativeButton("Hủy", null)
            .show()
    }
}


