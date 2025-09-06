package com.example.memeplayer

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

data class PlaybackHistory(
    val uri: String,
    val fileName: String,
    val position: Long,
    val duration: Long,
    val lastPlayed: Long
)

class PlaybackHistoryService(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("playback_history", Context.MODE_PRIVATE)
    private val gson = Gson()
    
    companion object {
        private const val HISTORY_KEY = "video_history"
        private const val MAX_HISTORY_SIZE = 50
    }
    
    fun savePlaybackPosition(uri: Uri, fileName: String, position: Long, duration: Long) {
        val history = getHistory().toMutableList()
        val uriString = uri.toString()
        
        // Remove existing entry if present
        history.removeAll { it.uri == uriString }
        
        // Add new entry at the beginning
        history.add(0, PlaybackHistory(
            uri = uriString,
            fileName = fileName,
            position = position,
            duration = duration,
            lastPlayed = System.currentTimeMillis()
        ))
        
        // Keep only the most recent entries
        if (history.size > MAX_HISTORY_SIZE) {
            history.subList(MAX_HISTORY_SIZE, history.size).clear()
        }
        
        saveHistory(history)
    }
    
    fun getPlaybackPosition(uri: Uri): Long {
        val uriString = uri.toString()
        return getHistory().find { it.uri == uriString }?.position ?: 0L
    }
    
    fun getHistory(): List<PlaybackHistory> {
        val json = prefs.getString(HISTORY_KEY, null) ?: return emptyList()
        return try {
            val type = object : TypeToken<List<PlaybackHistory>>() {}.type
            gson.fromJson(json, type) ?: emptyList()
        } catch (e: Exception) {
            emptyList()
        }
    }
    
    private fun saveHistory(history: List<PlaybackHistory>) {
        val json = gson.toJson(history)
        prefs.edit().putString(HISTORY_KEY, json).apply()
    }
    
    fun clearHistory() {
        prefs.edit().remove(HISTORY_KEY).apply()
    }
}