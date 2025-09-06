package com.example.memeplayer

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import java.io.File

class VideoFileAdapter(
    private val onItemClick: (FileItem) -> Unit
) : RecyclerView.Adapter<VideoFileAdapter.ViewHolder>() {

    private var items = listOf<FileItem>()

    fun updateItems(newItems: List<FileItem>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_file, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]
        holder.bind(item)
    }
    
    fun getItemAt(position: Int): FileItem? {
        return if (position in 0 until items.size) items[position] else null
    }

    override fun getItemCount(): Int = items.size

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val iconImageView: ImageView = itemView.findViewById(R.id.iconImageView)
        private val nameTextView: TextView = itemView.findViewById(R.id.nameTextView)
        private val sizeTextView: TextView = itemView.findViewById(R.id.sizeTextView)
        private val durationTextView: TextView = itemView.findViewById(R.id.durationTextView)

        fun bind(item: FileItem) {
            nameTextView.text = item.displayName
            
            when {
                item.isParentDirectory -> {
                    iconImageView.setImageResource(R.drawable.ic_arrow_back)
                    sizeTextView.text = "Quay lại"
                    durationTextView.visibility = View.GONE
                }
                item.isDirectory -> {
                    iconImageView.setImageResource(R.drawable.ic_folder)
                    sizeTextView.text = "Thư mục"
                    durationTextView.visibility = View.GONE
                }
                else -> {
                    iconImageView.setImageResource(R.drawable.ic_video)
                    sizeTextView.text = formatFileSize(item.file.length())
                    durationTextView.text = "Video"
                    durationTextView.visibility = View.VISIBLE
                }
            }
            
            itemView.setOnClickListener {
                onItemClick(item)
            }
        }

        private fun formatFileSize(bytes: Long): String {
            val kb = bytes / 1024.0
            val mb = kb / 1024.0
            val gb = mb / 1024.0
            
            return when {
                gb >= 1 -> String.format("%.1f GB", gb)
                mb >= 1 -> String.format("%.1f MB", mb)
                kb >= 1 -> String.format("%.1f KB", kb)
                else -> "$bytes B"
            }
        }
    }
}