package com.example.memeplayer.adapters

import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.R
import com.example.memeplayer.VideoPlayerActivity
import com.example.memeplayer.models.Video
import java.util.concurrent.TimeUnit

class VideoAdapter(private val videoList: List<Video>) : 
    RecyclerView.Adapter<VideoAdapter.VideoViewHolder>() {

    class VideoViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val titleTextView: TextView = itemView.findViewById(R.id.text_video_title)
        val durationTextView: TextView = itemView.findViewById(R.id.text_video_duration)
        val thumbnailImageView: ImageView = itemView.findViewById(R.id.image_video_thumbnail)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VideoViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_video, parent, false)
        return VideoViewHolder(view)
    }

    override fun onBindViewHolder(holder: VideoViewHolder, position: Int) {
        val video = videoList[position]
        holder.titleTextView.text = video.title
        holder.durationTextView.text = formatDuration(video.duration)
        
        // Hiển thị thumbnail mặc định
        holder.thumbnailImageView.setImageResource(R.drawable.ic_video_placeholder)
        
        // Thiết lập sự kiện click để phát video
        holder.itemView.setOnClickListener {
            val context = holder.itemView.context
            val intent = Intent(context, VideoPlayerActivity::class.java)
            intent.data = video.uri
            context.startActivity(intent)
        }
    }
    
    private fun formatDuration(durationMs: Long): String {
        val minutes = TimeUnit.MILLISECONDS.toMinutes(durationMs)
        val seconds = TimeUnit.MILLISECONDS.toSeconds(durationMs) % 60
        return String.format("%02d:%02d", minutes, seconds)
    }

    override fun getItemCount(): Int = videoList.size
}