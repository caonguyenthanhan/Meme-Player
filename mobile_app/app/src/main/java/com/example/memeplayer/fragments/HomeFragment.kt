package com.example.memeplayer.fragments

import android.content.ContentUris
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.DirectoryBrowserActivity
import com.example.memeplayer.R
import com.example.memeplayer.adapters.VideoAdapter
import com.example.memeplayer.models.Video
import com.google.android.material.button.MaterialButton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class HomeFragment : Fragment() {

    private lateinit var recyclerRecentVideos: RecyclerView
    private lateinit var videoAdapter: VideoAdapter
    private lateinit var btnBrowseVideos: MaterialButton
    private val recentVideoList = ArrayList<Video>()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_home, container, false)
        
        // Khởi tạo views
        recyclerRecentVideos = view.findViewById(R.id.recycler_recent_videos)
        btnBrowseVideos = view.findViewById(R.id.btn_browse_videos)
        
        // Thiết lập RecyclerView cho video với grid layout
        recyclerRecentVideos.layoutManager = GridLayoutManager(context, 2)
        videoAdapter = VideoAdapter(recentVideoList)
        recyclerRecentVideos.adapter = videoAdapter
        
        // Xử lý sự kiện click nút duyệt video
        btnBrowseVideos.setOnClickListener {
            val intent = Intent(requireContext(), DirectoryBrowserActivity::class.java)
            startActivity(intent)
        }
        
        return view
    }
    
    fun loadAllVideos() {
        CoroutineScope(Dispatchers.IO).launch {
            val videoList = scanAllVideos()
            withContext(Dispatchers.Main) {
                recentVideoList.clear()
                recentVideoList.addAll(videoList)
                videoAdapter.notifyDataSetChanged()
                
                if (videoList.isNotEmpty()) {
                    Toast.makeText(context, "Đã tìm thấy ${videoList.size} video", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(context, "Không tìm thấy video nào", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    
    private fun scanAllVideos(): List<Video> {
        val videoList = mutableListOf<Video>()
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.DATA
        )
        
        val selection = "${MediaStore.Video.Media.DURATION} >= ?"
        val selectionArgs = arrayOf("1000") // Chỉ lấy video dài hơn 1 giây
        val sortOrder = "${MediaStore.Video.Media.DATE_ADDED} DESC"
        
        val cursor: Cursor? = requireContext().contentResolver.query(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            sortOrder
        )
        
        cursor?.use {
            val idColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
            val nameColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
            val durationColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
            val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
            val dataColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
            
            while (it.moveToNext()) {
                val id = it.getLong(idColumn)
                val name = it.getString(nameColumn)
                val duration = it.getLong(durationColumn)
                val size = it.getLong(sizeColumn)
                val path = it.getString(dataColumn)
                
                val contentUri = ContentUris.withAppendedId(
                    MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                    id
                )
                
                val video = Video(
                    name = name,
                    path = path,
                    uri = contentUri,
                    duration = duration,
                    size = size
                )
                videoList.add(video)
            }
        }
        
        return videoList
    }
}