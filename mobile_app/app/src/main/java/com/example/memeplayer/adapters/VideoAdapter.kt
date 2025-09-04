package com.example.memeplayer.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.R
import com.example.memeplayer.models.Video

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
        holder.durationTextView.text = video.duration
        
        // Trong ứng dụng thực tế, bạn sẽ sử dụng thư viện như Glide hoặc Picasso để tải hình ảnh
        // Glide.with(holder.itemView.context).load(video.thumbnailUrl).into(holder.thumbnailImageView)
        
        // Thiết lập sự kiện click cho item
        holder.itemView.setOnClickListener {
            // Xử lý khi người dùng nhấn vào video
            // Ví dụ: mở màn hình phát video
        }
    }

    override fun getItemCount(): Int = videoList.size
}