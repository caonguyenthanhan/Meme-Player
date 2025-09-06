package com.example.memeplayer.models

import android.net.Uri

data class Video(
    val name: String,
    val path: String,
    val uri: Uri,
    val duration: Long = 0L,
    val size: Long = 0L,
    val id: String = java.util.UUID.randomUUID().toString()
) {
    // Getter cho compatibility với code cũ
    val title: String get() = name
    val thumbnailUrl: String get() = "" // Sẽ được tạo từ video
}