package com.example.memeplayer

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

data class SubtitleSettings(
    val subtitlePath: String? = null,
    val fontSize: Float = 18f,
    val textColor: Int = -1, // White
    val backgroundColor: Int = 0x80000000.toInt(), // Semi-transparent black
    val fontStyle: String = "Default",
    val opacity: Float = 0.53f,
    val isEnabled: Boolean = false
)

class SubtitlePreferencesService(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("subtitle_preferences", Context.MODE_PRIVATE)
    private val gson = Gson()
    
    companion object {
        private const val SUBTITLE_SETTINGS_KEY = "subtitle_settings"
    }
    
    fun saveSubtitleSettings(videoUri: Uri, settings: SubtitleSettings) {
        val allSettings = getAllSubtitleSettings().toMutableMap()
        allSettings[videoUri.toString()] = settings
        saveAllSettings(allSettings)
    }
    
    fun getSubtitleSettings(videoUri: Uri): SubtitleSettings {
        val allSettings = getAllSubtitleSettings()
        return allSettings[videoUri.toString()] ?: SubtitleSettings()
    }
    
    fun hasSubtitleSettings(videoUri: Uri): Boolean {
        val allSettings = getAllSubtitleSettings()
        return allSettings.containsKey(videoUri.toString())
    }
    
    fun removeSubtitleSettings(videoUri: Uri) {
        val allSettings = getAllSubtitleSettings().toMutableMap()
        allSettings.remove(videoUri.toString())
        saveAllSettings(allSettings)
    }
    
    private fun getAllSubtitleSettings(): Map<String, SubtitleSettings> {
        val json = prefs.getString(SUBTITLE_SETTINGS_KEY, null) ?: return emptyMap()
        return try {
            val type = object : TypeToken<Map<String, SubtitleSettings>>() {}.type
            gson.fromJson(json, type) ?: emptyMap()
        } catch (e: Exception) {
            emptyMap()
        }
    }
    
    private fun saveAllSettings(settings: Map<String, SubtitleSettings>) {
        val json = gson.toJson(settings)
        prefs.edit().putString(SUBTITLE_SETTINGS_KEY, json).apply()
    }
    
    fun clearAllSettings() {
        prefs.edit().remove(SUBTITLE_SETTINGS_KEY).apply()
    }
}