package com.example.memeplayer.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.memeplayer.R
import com.example.memeplayer.adapters.PlaylistAdapter
import com.example.memeplayer.models.Playlist

class LibraryFragment : Fragment() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var playlistAdapter: PlaylistAdapter
    private val playlistList = ArrayList<Playlist>()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_library, container, false)
        
        recyclerView = view.findViewById(R.id.recycler_playlists)
        recyclerView.layoutManager = GridLayoutManager(context, 2)
        
        // Thêm dữ liệu mẫu
        loadSampleData()
        
        // Khởi tạo adapter
        playlistAdapter = PlaylistAdapter(playlistList)
        recyclerView.adapter = playlistAdapter
        
        return view
    }
    
    private fun loadSampleData() {
        playlistList.add(Playlist("Meme Yêu Thích", 12))
        playlistList.add(Playlist("Meme Hài Hước", 8))
        playlistList.add(Playlist("Meme Động Vật", 5))
        playlistList.add(Playlist("Meme Anime", 15))
        playlistList.add(Playlist("Meme Game", 7))
        playlistList.add(Playlist("Meme Phim", 10))
    }
}