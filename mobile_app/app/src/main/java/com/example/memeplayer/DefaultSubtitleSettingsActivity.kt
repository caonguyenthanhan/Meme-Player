package com.example.memeplayer

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity

class DefaultSubtitleSettingsActivity : AppCompatActivity() {
    
    private lateinit var sharedPrefs: SharedPreferences
    
    // Default settings
    private var defaultTextSize: Float = 18f
    private var defaultTextColor: Int = Color.WHITE
    private var defaultBackgroundColor: Int = Color.BLACK
    private var defaultBackgroundOpacity: Float = 0.7f
    private var defaultFontFamily: String = "default"
    private var defaultEnabled: Boolean = true
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_default_subtitle_settings)
        
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = "Cài đặt phụ đề mặc định"
        
        sharedPrefs = getSharedPreferences("default_subtitle_settings", Context.MODE_PRIVATE)
        
        loadDefaultSettings()
        setupUI()
    }
    
    private fun loadDefaultSettings() {
        defaultTextSize = sharedPrefs.getFloat("text_size", 18f)
        defaultTextColor = sharedPrefs.getInt("text_color", Color.WHITE)
        defaultBackgroundColor = sharedPrefs.getInt("background_color", Color.BLACK)
        defaultBackgroundOpacity = sharedPrefs.getFloat("background_opacity", 0.7f)
        defaultFontFamily = sharedPrefs.getString("font_family", "default") ?: "default"
        defaultEnabled = sharedPrefs.getBoolean("enabled", true)
    }
    
    private fun setupUI() {
        val seekTextSize = findViewById<SeekBar>(R.id.seekbar_default_font_size)
        val txtTextSizeValue = findViewById<TextView>(R.id.txt_default_font_size)
        val seekBackgroundOpacity = findViewById<SeekBar>(R.id.seekbar_default_bg_opacity)
        val txtOpacityValue = findViewById<TextView>(R.id.txt_default_bg_opacity)
        val spinnerFontFamily = findViewById<Spinner>(R.id.spinner_default_font_family)
        val txtPreview = findViewById<TextView>(R.id.txt_default_preview)
        val switchEnabled = findViewById<Switch>(R.id.switch_default_enabled)
        
        // Color buttons
        val btnColorWhite = findViewById<Button>(R.id.btn_default_color_white)
        val btnColorYellow = findViewById<Button>(R.id.btn_default_color_yellow)
        val btnColorRed = findViewById<Button>(R.id.btn_default_color_red)
        val btnColorGreen = findViewById<Button>(R.id.btn_default_color_green)
        val btnColorBlue = findViewById<Button>(R.id.btn_default_color_blue)
        val btnColorPicker = findViewById<Button>(R.id.btn_default_color_picker)
        
        // Background color buttons
        val btnBgTransparent = findViewById<Button>(R.id.btn_default_bg_transparent)
        val btnBgBlack = findViewById<Button>(R.id.btn_default_bg_black)
        val btnBgGray = findViewById<Button>(R.id.btn_default_bg_gray)
        val btnBgWhite = findViewById<Button>(R.id.btn_default_bg_white)
        val btnBgColorPicker = findViewById<Button>(R.id.btn_default_bg_color_picker)
        
        val btnSave = findViewById<Button>(R.id.btn_save_default_settings)
        val btnReset = findViewById<Button>(R.id.btn_reset_default_settings)
        
        // Update preview function
        fun updatePreview() {
            txtPreview.textSize = defaultTextSize
            txtPreview.setTextColor(defaultTextColor)
            txtPreview.setBackgroundColor(Color.argb(
                (defaultBackgroundOpacity * 255).toInt(),
                Color.red(defaultBackgroundColor),
                Color.green(defaultBackgroundColor),
                Color.blue(defaultBackgroundColor)
            ))
            
            val typeface = when (defaultFontFamily) {
                "serif" -> Typeface.SERIF
                "sans-serif" -> Typeface.SANS_SERIF
                "monospace" -> Typeface.MONOSPACE
                else -> Typeface.DEFAULT
            }
            txtPreview.typeface = typeface
        }
        
        // Set initial values
        seekTextSize.max = 40
        seekTextSize.progress = (defaultTextSize - 10f).toInt()
        txtTextSizeValue.text = "${defaultTextSize.toInt()}sp"
        
        seekBackgroundOpacity.max = 100
        seekBackgroundOpacity.progress = (defaultBackgroundOpacity * 100).toInt()
        txtOpacityValue.text = "${(defaultBackgroundOpacity * 100).toInt()}%"
        
        switchEnabled.isChecked = defaultEnabled
        
        // Setup font family spinner
        val fontFamilies = arrayOf("Default", "Serif", "Sans Serif", "Monospace")
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, fontFamilies)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        spinnerFontFamily.adapter = adapter
        
        val initialFontIndex = when (defaultFontFamily) {
            "serif" -> 1
            "sans-serif" -> 2
            "monospace" -> 3
            else -> 0
        }
        spinnerFontFamily.setSelection(initialFontIndex)
        
        txtPreview.text = "Đây là phụ đề mặc định"
        updatePreview()
        
        // Setup listeners
        seekTextSize.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                defaultTextSize = 10f + progress
                txtTextSizeValue.text = "${defaultTextSize.toInt()}sp"
                updatePreview()
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        seekBackgroundOpacity.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                defaultBackgroundOpacity = progress / 100f
                txtOpacityValue.text = "${progress}%"
                updatePreview()
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        spinnerFontFamily.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: android.view.View?, position: Int, id: Long) {
                defaultFontFamily = when (position) {
                    1 -> "serif"
                    2 -> "sans-serif"
                    3 -> "monospace"
                    else -> "default"
                }
                updatePreview()
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
        
        switchEnabled.setOnCheckedChangeListener { _, isChecked ->
            defaultEnabled = isChecked
        }
        
        // Color button listeners
        btnColorWhite.setOnClickListener {
            defaultTextColor = Color.WHITE
            updatePreview()
        }
        btnColorYellow.setOnClickListener {
            defaultTextColor = Color.YELLOW
            updatePreview()
        }
        btnColorRed.setOnClickListener {
            defaultTextColor = Color.RED
            updatePreview()
        }
        btnColorGreen.setOnClickListener {
            defaultTextColor = Color.GREEN
            updatePreview()
        }
        btnColorBlue.setOnClickListener {
            defaultTextColor = Color.BLUE
            updatePreview()
        }
        
        // Background color button listeners
        btnBgTransparent.setOnClickListener {
            defaultBackgroundColor = Color.TRANSPARENT
            updatePreview()
        }
        btnBgBlack.setOnClickListener {
            defaultBackgroundColor = Color.BLACK
            updatePreview()
        }
        btnBgGray.setOnClickListener {
            defaultBackgroundColor = Color.GRAY
            updatePreview()
        }
        btnBgWhite.setOnClickListener {
            defaultBackgroundColor = Color.WHITE
            updatePreview()
        }
        
        // Color picker buttons
        btnColorPicker.setOnClickListener {
            showColorPicker("Chọn màu chữ mặc định") { color ->
                defaultTextColor = color
                updatePreview()
            }
        }
        
        btnBgColorPicker.setOnClickListener {
            showColorPicker("Chọn màu nền mặc định") { color ->
                defaultBackgroundColor = color
                updatePreview()
            }
        }
        
        // Save button
        btnSave.setOnClickListener {
            saveDefaultSettings()
            Toast.makeText(this, "Đã lưu cài đặt mặc định", Toast.LENGTH_SHORT).show()
            finish()
        }
        
        // Reset button
        btnReset.setOnClickListener {
            AlertDialog.Builder(this)
                .setTitle("Đặt lại cài đặt")
                .setMessage("Bạn có chắc muốn đặt lại về cài đặt mặc định?")
                .setPositiveButton("Đặt lại") { _, _ ->
                    resetToDefaults()
                    setupUI() // Refresh UI
                    Toast.makeText(this, "Đã đặt lại cài đặt mặc định", Toast.LENGTH_SHORT).show()
                }
                .setNegativeButton("Hủy", null)
                .show()
        }
    }
    
    private fun saveDefaultSettings() {
        sharedPrefs.edit().apply {
            putFloat("text_size", defaultTextSize)
            putInt("text_color", defaultTextColor)
            putInt("background_color", defaultBackgroundColor)
            putFloat("background_opacity", defaultBackgroundOpacity)
            putString("font_family", defaultFontFamily)
            putBoolean("enabled", defaultEnabled)
            apply()
        }
    }
    
    private fun resetToDefaults() {
        defaultTextSize = 18f
        defaultTextColor = Color.WHITE
        defaultBackgroundColor = Color.BLACK
        defaultBackgroundOpacity = 0.7f
        defaultFontFamily = "default"
        defaultEnabled = true
        saveDefaultSettings()
    }
    
    private fun showColorPicker(title: String, onColorSelected: (Int) -> Unit) {
        val colors = arrayOf(
            Color.WHITE, Color.YELLOW, Color.RED, Color.GREEN, Color.BLUE,
            Color.CYAN, Color.MAGENTA, Color.BLACK, Color.GRAY, Color.LTGRAY
        )
        
        val colorNames = arrayOf(
            "Trắng", "Vàng", "Đỏ", "Xanh lá", "Xanh dương",
            "Xanh lơ", "Tím", "Đen", "Xám", "Xám nhạt"
        )
        
        AlertDialog.Builder(this)
            .setTitle(title)
            .setItems(colorNames) { _, which ->
                onColorSelected(colors[which])
            }
            .show()
    }
    
    override fun onSupportNavigateUp(): Boolean {
        onBackPressed()
        return true
    }
    
    companion object {
        fun getDefaultSettings(context: Context): SubtitleSettings {
            val prefs = context.getSharedPreferences("default_subtitle_settings", Context.MODE_PRIVATE)
            return SubtitleSettings(
                subtitlePath = null,
                fontSize = prefs.getFloat("text_size", 18f),
                textColor = prefs.getInt("text_color", Color.WHITE),
                backgroundColor = prefs.getInt("background_color", Color.BLACK),
                fontStyle = prefs.getString("font_family", "default") ?: "default",
                opacity = prefs.getFloat("background_opacity", 0.7f),
                isEnabled = prefs.getBoolean("enabled", true)
            )
        }
    }
}