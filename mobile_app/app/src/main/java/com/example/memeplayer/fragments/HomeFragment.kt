package com.example.memeplayer.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.R
import com.example.memeplayer.adapters.VideoAdapter
import com.example.memeplayer.models.Video

class HomeFragment : Fragment() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var videoAdapter: VideoAdapter
    private val videoList = ArrayList<Video>()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_home, container, false)
        
        recyclerView = view.findViewById(R.id.recycler_videos)
        recyclerView.layoutManager = LinearLayoutManager(context)
        
        // Thêm dữ liệu mẫu
        loadSampleData()
        
        // Khởi tạo adapter
        videoAdapter = VideoAdapter(videoList)
        recyclerView.adapter = videoAdapter
        
        return view
    }
    
    private fun loadSampleData() {
        videoList.add(Video("Meme Video 1", "https://example.com/thumbnail1.jpg", "00:30"))
        videoList.add(Video("Meme Video 2", "https://example.com/thumbnail2.jpg", "01:15"))
        videoList.add(Video("Meme Video 3", "https://example.com/thumbnail3.jpg", "00:45"))
        videoList.add(Video("Meme Video 4", "https://example.com/thumbnail4.jpg", "02:10"))
        videoList.add(Video("Meme Video 5", "https://example.com/thumbnail5.jpg", "01:30"))
    }
}