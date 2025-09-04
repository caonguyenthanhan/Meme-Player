package com.example.memeplayer.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.R
import com.example.memeplayer.models.Playlist

class PlaylistAdapter(private val playlistList: List<Playlist>) : 
    RecyclerView.Adapter<PlaylistAdapter.PlaylistViewHolder>() {

    class PlaylistViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val nameTextView: TextView = itemView.findViewById(R.id.text_playlist_name)
        val countTextView: TextView = itemView.findViewById(R.id.text_video_count)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PlaylistViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_playlist, parent, false)
        return PlaylistViewHolder(view)
    }

    override fun onBindViewHolder(holder: PlaylistViewHolder, position: Int) {
        val playlist = playlistList[position]
        holder.nameTextView.text = playlist.name
        holder.countTextView.text = "${playlist.videoCount} video"
        
        // Thiết lập sự kiện click cho item
        holder.itemView.setOnClickListener {
            // Xử lý khi người dùng nhấn vào playlist
            // Ví dụ: mở danh sách video trong playlist
        }
    }

    override fun getItemCount(): Int = playlistList.size
}