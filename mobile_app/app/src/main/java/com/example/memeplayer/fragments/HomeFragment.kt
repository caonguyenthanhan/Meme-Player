package com.example.memeplayer.fragments

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.DirectoryBrowserActivity
import com.example.memeplayer.R
import com.example.memeplayer.adapters.VideoAdapter
import com.example.memeplayer.models.Video
import com.google.android.material.button.MaterialButton

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
        
        // Thiết lập RecyclerView cho video gần đây
        recyclerRecentVideos.layoutManager = LinearLayoutManager(context)
        videoAdapter = VideoAdapter(recentVideoList)
        recyclerRecentVideos.adapter = videoAdapter
        
        // Xử lý sự kiện click nút duyệt video
        btnBrowseVideos.setOnClickListener {
            val intent = Intent(requireContext(), DirectoryBrowserActivity::class.java)
            startActivity(intent)
        }
        
        return view
    }
}