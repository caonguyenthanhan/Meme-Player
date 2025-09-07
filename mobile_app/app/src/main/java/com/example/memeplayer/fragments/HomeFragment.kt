package com.example.memeplayer.fragments

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.DirectoryBrowserActivity
import com.example.memeplayer.PlaybackHistoryService
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
    private lateinit var tvRecentVideosTitle: View
    private lateinit var videoAdapter: VideoAdapter
    private lateinit var btnBrowseVideos: MaterialButton
    private val recentVideoList = ArrayList<Video>()
    private val allVideoList = ArrayList<Video>()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_home, container, false)
        
        // Khởi tạo views
        recyclerRecentVideos = view.findViewById(R.id.recycler_recent_videos)
        tvRecentVideosTitle = view.findViewById(R.id.tv_recent_videos_title)
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
        
        // Load video gần đây khi fragment được tạo
        loadRecentVideos()
        
        return view
    }
    
    fun loadRecentVideos() {
        CoroutineScope(Dispatchers.IO).launch {
            val historyService = PlaybackHistoryService(requireContext())
            val recentHistory = historyService.getHistory().take(10) // Lấy 10 video gần đây nhất
            
            val recentVideoList = mutableListOf<Video>()
            for (history in recentHistory) {
                try {
                    val uri = Uri.parse(history.uri)
                    val video = Video(
                        name = history.fileName,
                        path = "",
                        uri = uri,
                        duration = history.duration,
                        size = 0L
                    )
                    recentVideoList.add(video)
                } catch (e: Exception) {
                    // Bỏ qua video không hợp lệ
                }
            }
            
            withContext(Dispatchers.Main) {
                this@HomeFragment.recentVideoList.clear()
                this@HomeFragment.recentVideoList.addAll(recentVideoList)
                videoAdapter.notifyDataSetChanged()
                
                if (recentVideoList.isNotEmpty()) {
                    // Hiển thị tiêu đề và RecyclerView khi có lịch sử
                    tvRecentVideosTitle.visibility = View.VISIBLE
                    recyclerRecentVideos.visibility = View.VISIBLE
                    Toast.makeText(context, "Lịch sử: ${recentVideoList.size} video gần đây", Toast.LENGTH_SHORT).show()
                } else {
                    // Ẩn tiêu đề và RecyclerView khi không có lịch sử
                    tvRecentVideosTitle.visibility = View.GONE
                    recyclerRecentVideos.visibility = View.GONE
                    Toast.makeText(context, "Chưa có lịch sử video", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    
    fun loadAllVideos() {
        loadRecentVideos()
    }

}