package com.example.memeplayer.models

data class Video(
    val title: String,
    val thumbnailUrl: String,
    val duration: String,
    val id: String = java.util.UUID.randomUUID().toString()
)