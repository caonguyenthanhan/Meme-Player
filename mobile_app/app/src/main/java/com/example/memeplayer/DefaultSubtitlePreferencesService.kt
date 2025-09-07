package com.example.memeplayer

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.Typeface

class DefaultSubtitlePreferencesService(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("default_subtitle_prefs", Context.MODE_PRIVATE)
    
    companion object {
        private const val KEY_ENABLED = "default_enabled"
        private const val KEY_FONT_SIZE = "default_font_size"
        private const val KEY_TEXT_COLOR = "default_text_color"
        private const val KEY_BACKGROUND_COLOR = "default_background_color"
        private const val KEY_BACKGROUND_OPACITY = "default_background_opacity"
        private const val KEY_FONT_FAMILY = "default_font_family"
    }
    
    data class DefaultSubtitleSettings(
        val enabled: Boolean = true,
        val fontSize: Float = 18f,
        val textColor: Int = Color.WHITE,
        val backgroundColor: Int = Color.BLACK,
        val backgroundOpacity: Float = 0.7f,
        val fontFamily: String = "default"
    )
    
    fun saveDefaultSettings(settings: DefaultSubtitleSettings) {
        prefs.edit().apply {
            putBoolean(KEY_ENABLED, settings.enabled)
            putFloat(KEY_FONT_SIZE, settings.fontSize)
            putInt(KEY_TEXT_COLOR, settings.textColor)
            putInt(KEY_BACKGROUND_COLOR, settings.backgroundColor)
            putFloat(KEY_BACKGROUND_OPACITY, settings.backgroundOpacity)
            putString(KEY_FONT_FAMILY, settings.fontFamily)
            apply()
        }
    }
    
    fun getDefaultSettings(): DefaultSubtitleSettings {
        return DefaultSubtitleSettings(
            enabled = prefs.getBoolean(KEY_ENABLED, true),
            fontSize = prefs.getFloat(KEY_FONT_SIZE, 18f),
            textColor = prefs.getInt(KEY_TEXT_COLOR, Color.WHITE),
            backgroundColor = prefs.getInt(KEY_BACKGROUND_COLOR, Color.BLACK),
            backgroundOpacity = prefs.getFloat(KEY_BACKGROUND_OPACITY, 0.7f),
            fontFamily = prefs.getString(KEY_FONT_FAMILY, "default") ?: "default"
        )
    }
    
    fun resetToDefaults() {
        saveDefaultSettings(DefaultSubtitleSettings())
    }
    
    fun isDefaultEnabled(): Boolean {
        return prefs.getBoolean(KEY_ENABLED, true)
    }
    
    fun getTypefaceFromFamily(fontFamily: String): Typeface {
        return when (fontFamily) {
            "serif" -> Typeface.SERIF
            "sans_serif" -> Typeface.SANS_SERIF
            "monospace" -> Typeface.MONOSPACE
            else -> Typeface.DEFAULT
        }
    }
}