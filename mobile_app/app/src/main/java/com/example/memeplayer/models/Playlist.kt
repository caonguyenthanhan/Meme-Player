package com.example.memeplayer.models

data class Playlist(
    val name: String,
    val videoCount: Int,
    val id: String = java.util.UUID.randomUUID().toString()
)