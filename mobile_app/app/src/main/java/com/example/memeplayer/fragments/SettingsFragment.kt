package com.example.memeplayer.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.Switch
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.example.memeplayer.R

class SettingsFragment : Fragment() {

    private lateinit var darkModeSwitch: Switch
    private lateinit var autoSubtitleSwitch: Switch
    private lateinit var videoEnhancerSwitch: Switch
    private lateinit var audioEnhancerSwitch: Switch
    private lateinit var clearCacheButton: Button

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_settings, container, false)
        
        // Khởi tạo các thành phần UI
        darkModeSwitch = view.findViewById(R.id.switch_dark_mode)
        autoSubtitleSwitch = view.findViewById(R.id.switch_auto_subtitle)
        videoEnhancerSwitch = view.findViewById(R.id.switch_video_enhancer)
        audioEnhancerSwitch = view.findViewById(R.id.switch_audio_enhancer)
        clearCacheButton = view.findViewById(R.id.button_clear_cache)
        
        // Thiết lập sự kiện click cho nút xóa cache
        clearCacheButton.setOnClickListener {
            Toast.makeText(context, "Đã xóa cache", Toast.LENGTH_SHORT).show()
        }
        
        // Thiết lập sự kiện thay đổi cho các switch
        setupSwitchListeners()
        
        return view
    }
    
    private fun setupSwitchListeners() {
        darkModeSwitch.setOnCheckedChangeListener { _, isChecked ->
            val message = if (isChecked) "Đã bật chế độ tối" else "Đã tắt chế độ tối"
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
        
        autoSubtitleSwitch.setOnCheckedChangeListener { _, isChecked ->
            val message = if (isChecked) "Đã bật tự động tạo phụ đề" else "Đã tắt tự động tạo phụ đề"
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
        
        videoEnhancerSwitch.setOnCheckedChangeListener { _, isChecked ->
            val message = if (isChecked) "Đã bật nâng cao chất lượng video" else "Đã tắt nâng cao chất lượng video"
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
        
        audioEnhancerSwitch.setOnCheckedChangeListener { _, isChecked ->
            val message = if (isChecked) "Đã bật nâng cao chất lượng âm thanh" else "Đã tắt nâng cao chất lượng âm thanh"
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
    }
}