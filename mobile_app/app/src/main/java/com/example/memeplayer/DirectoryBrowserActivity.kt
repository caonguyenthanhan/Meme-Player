package com.example.memeplayer

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.database.Cursor
import android.content.ContentResolver
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SearchView
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
// import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import androidx.recyclerview.widget.RecyclerView
import java.io.File
import android.hardware.usb.UsbManager
import android.content.Context
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.os.Build
import androidx.annotation.RequiresApi

class DirectoryBrowserActivity : AppCompatActivity() {
    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: VideoFileAdapter
    private lateinit var toolbar: Toolbar
    // private lateinit var swipeRefreshLayout: SwipeRefreshLayout
    private var currentDirectory: File = Environment.getExternalStorageDirectory()
    private val videoExtensions = setOf("mp4", "avi", "mkv", "mov", "wmv", "flv", "webm", "m4v", "3gp")
    private var allFiles = listOf<FileItem>()
    private var isGridView = true
    private var isShowingMediaFiles = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_directory_browser)
        
        setupToolbar()
         setupSwipeRefresh()
         setupRecyclerView()
         loadMediaFiles()
     }
     
     private fun setupToolbar() {
         toolbar = findViewById(R.id.toolbar)
         setSupportActionBar(toolbar)
         supportActionBar?.setDisplayHomeAsUpEnabled(true)
         supportActionBar?.setDisplayShowHomeEnabled(true)
         updateToolbarTitle()
     }
     
     private fun setupSwipeRefresh() {
        // SwipeRefreshLayout temporarily disabled
        // swipeRefreshLayout = findViewById<SwipeRefreshLayout>(R.id.swipeRefreshLayout)
        // swipeRefreshLayout.setColorSchemeResources(
        //     android.R.color.holo_blue_bright,
        //     android.R.color.holo_green_light,
        //     android.R.color.holo_orange_light
        // )
        // swipeRefreshLayout.setOnRefreshListener {
        //     loadDirectory(currentDirectory)
        //     swipeRefreshLayout.isRefreshing = false
        // }
    }

    private fun setupRecyclerView() {
        recyclerView = findViewById(R.id.recyclerView)
        updateLayoutManager()
        
        adapter = VideoFileAdapter { fileItem ->
            if (fileItem.isDirectory) {
                if (isShowingMediaFiles && fileItem.displayName.contains("Duyệt thư mục")) {
                    loadDirectory(currentDirectory)
                } else if (isShowingMediaFiles && fileItem.displayName.contains("USB Storage")) {
                    showUsbStorageOptions()
                } else if (!isShowingMediaFiles && fileItem.displayName.contains("Quay lại danh sách video")) {
                    loadMediaFiles()
                } else {
                    loadDirectory(fileItem.file)
                }
            } else {
                playVideo(fileItem.file)
            }
        }
        recyclerView.adapter = adapter
    }
    
    private fun updateLayoutManager() {
        recyclerView.layoutManager = if (isGridView) {
            GridLayoutManager(this, 2)
        } else {
            LinearLayoutManager(this)
        }
    }
    
    private fun updateToolbarTitle() {
        val pathParts = currentDirectory.absolutePath.split("/")
        val displayPath = if (pathParts.size > 3) {
            ".../${pathParts.takeLast(2).joinToString("/")}"
        } else {
            currentDirectory.name.ifEmpty { "Thư mục gốc" }
        }
        supportActionBar?.title = displayPath
    }

    private fun getUsbStorages(): List<File> {
        val usbStorages = mutableListOf<File>()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val storageManager = getSystemService(Context.STORAGE_SERVICE) as StorageManager
                val storageVolumes = storageManager.storageVolumes
                
                for (volume in storageVolumes) {
                    if (volume.isRemovable && !volume.isPrimary) {
                        // Try to get the path for removable storage
                        val volumePath = getVolumePath(volume)
                        if (volumePath != null) {
                            val usbDir = File(volumePath)
                            if (usbDir.exists() && usbDir.canRead()) {
                                usbStorages.add(usbDir)
                            }
                        }
                    }
                }
            }
            
            // Fallback: Check common USB mount points
            val commonUsbPaths = listOf(
                "/storage/usbotg",
                "/storage/usb",
                "/mnt/usb",
                "/mnt/usbotg",
                "/storage/sda1",
                "/storage/sdb1",
                "/storage/sdc1",
                "/storage/sdd1",
                "/mnt/media_rw",
                "/storage/extSdCard",
                "/storage/external_SD",
                "/storage/removable"
            )
            
            // Also check /storage directory for any removable storage
            try {
                val storageDir = File("/storage")
                if (storageDir.exists() && storageDir.isDirectory) {
                    storageDir.listFiles()?.forEach { dir ->
                        if (dir.isDirectory && dir.canRead() && 
                            !dir.name.equals("emulated", ignoreCase = true) &&
                            !dir.name.equals("self", ignoreCase = true) &&
                            !usbStorages.contains(dir)) {
                            usbStorages.add(dir)
                        }
                    }
                }
            } catch (e: Exception) {
                // Ignore errors
            }
            
            for (path in commonUsbPaths) {
                val usbDir = File(path)
                if (usbDir.exists() && usbDir.canRead() && !usbStorages.contains(usbDir)) {
                    usbStorages.add(usbDir)
                }
            }
            
        } catch (e: Exception) {
            // Ignore errors in USB detection
        }
        return usbStorages
    }
    
    @RequiresApi(Build.VERSION_CODES.N)
     private fun getVolumePath(volume: StorageVolume): String? {
         return try {
             val getPathMethod = volume.javaClass.getMethod("getPath")
             getPathMethod.invoke(volume) as? String
         } catch (e: Exception) {
             null
         }
     }
     
     private fun showUsbStorageOptions() {
         val usbStorages = getUsbStorages()
         if (usbStorages.isEmpty()) {
             androidx.appcompat.app.AlertDialog.Builder(this)
                 .setTitle("USB Storage không khả dụng")
                 .setMessage("Không tìm thấy USB storage nào.\n\nHướng dẫn:\n• Đảm bảo USB đã được cắm vào điện thoại\n• Kiểm tra USB có hỗ trợ OTG không\n• Thử rút và cắm lại USB\n• Một số thiết bị cần bật chế độ OTG trong cài đặt")
                 .setPositiveButton("Thử lại") { _, _ ->
                     showUsbStorageOptions()
                 }
                 .setNegativeButton("Đóng", null)
                 .show()
             return
         }
         
         if (usbStorages.size == 1) {
             // Directly browse the single USB storage
             loadDirectory(usbStorages[0])
         } else {
             // Show selection dialog for multiple USB storages
             val options = usbStorages.mapIndexed { index, file ->
                 "💾 USB ${index + 1}: ${file.name}"
             }.toTypedArray()
             
             androidx.appcompat.app.AlertDialog.Builder(this)
                 .setTitle("Chọn USB Storage")
                 .setItems(options) { _, which ->
                     loadDirectory(usbStorages[which])
                 }
                 .setNegativeButton("Hủy", null)
                 .show()
         }
     }

    private fun loadMediaFiles() {
        try {
            isShowingMediaFiles = true
            supportActionBar?.title = "Video trên thiết bị"
            
            val items = mutableListOf<FileItem>()
            
            // Query video files from MediaStore
            val projection = arrayOf(
                MediaStore.Video.Media._ID,
                MediaStore.Video.Media.DISPLAY_NAME,
                MediaStore.Video.Media.DATA,
                MediaStore.Video.Media.SIZE,
                MediaStore.Video.Media.DURATION
            )
            
            // Query both external and internal storage
            val uris = listOf(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                MediaStore.Video.Media.INTERNAL_CONTENT_URI
            )
            
            for (uri in uris) {
                val cursor: Cursor? = contentResolver.query(
                    uri,
                    projection,
                    null,
                    null,
                    "${MediaStore.Video.Media.DISPLAY_NAME} ASC"
                )
                
                cursor?.use {
                    val dataColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                    val nameColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
                    val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
                    val durationColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
                    
                    while (it.moveToNext()) {
                        val filePath = it.getString(dataColumn)
                        val fileName = it.getString(nameColumn)
                        val fileSize = it.getLong(sizeColumn)
                        val duration = it.getLong(durationColumn)
                        
                        val file = File(filePath)
                        if (file.exists()) {
                            val sizeText = formatFileSize(fileSize)
                            val durationText = formatDuration(duration)
                            val storageType = if (filePath.contains("/storage/emulated/0/")) "📱 Bộ nhớ trong" else "💾 Ổ nhớ ngoài"
                            val displayName = "🎬 ${file.nameWithoutExtension}\n📁 ${file.parent?.split("/")?.lastOrNull() ?: "Unknown"} • $storageType\n⏱️ $durationText • 📦 $sizeText"
                            items.add(FileItem(file, displayName, false, false))
                        }
                    }
                }
            }
            
            // Add option to browse folders
            items.add(0, FileItem(currentDirectory, "📂 Duyệt thư mục", true, false))
            
            // Add USB storage option if available
            val usbStorages = getUsbStorages()
            if (usbStorages.isNotEmpty()) {
                items.add(1, FileItem(usbStorages[0], "💾 USB Storage (${usbStorages.size} thiết bị)", true, false))
            }
            
            allFiles = items
            adapter.updateItems(items)
            
        } catch (e: Exception) {
            Toast.makeText(this, "Không thể tải video: ${e.message}", Toast.LENGTH_SHORT).show()
            loadDirectory(currentDirectory)
        }
    }
    
    private fun formatFileSize(bytes: Long): String {
        val kb = bytes / 1024.0
        val mb = kb / 1024.0
        val gb = mb / 1024.0
        
        return when {
            gb >= 1 -> String.format("%.1f GB", gb)
            mb >= 1 -> String.format("%.1f MB", mb)
            else -> String.format("%.0f KB", kb)
        }
    }
    
    private fun formatDuration(milliseconds: Long): String {
        val seconds = milliseconds / 1000
        val minutes = seconds / 60
        val hours = minutes / 60
        
        return when {
            hours > 0 -> String.format("%d:%02d:%02d", hours, minutes % 60, seconds % 60)
            else -> String.format("%d:%02d", minutes, seconds % 60)
        }
    }

    private fun loadDirectory(directory: File) {
        try {
            isShowingMediaFiles = false
            currentDirectory = directory
            updateToolbarTitle()
            
            val files = directory.listFiles()?.filter { file ->
                file.isDirectory || isVideoFile(file)
            }?.sortedWith(compareBy<File> { !it.isDirectory }.thenBy { it.name.lowercase() }) ?: emptyList()
            
            val items = mutableListOf<FileItem>()
            
            // Add back to media files option
            items.add(FileItem(currentDirectory, "🔙 Quay lại danh sách video", true, true))
            
            // Add parent directory option if not at root
            if (directory.parent != null) {
                items.add(FileItem(File(directory.parent!!), ".. (Thư mục cha)", true, true))
            }
            
            // Add directories and video files
            files.forEach { file ->
                val displayName = if (file.isDirectory) {
                    "📁 ${file.name}"
                } else {
                    "🎬 ${file.nameWithoutExtension}"
                }
                items.add(FileItem(file, displayName, file.isDirectory, false))
            }
            
            allFiles = items
            adapter.updateItems(items)
            
        } catch (e: Exception) {
            Toast.makeText(this, "Không thể truy cập thư mục: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun isVideoFile(file: File): Boolean {
        val extension = file.extension.lowercase()
        return videoExtensions.contains(extension)
    }

    private fun playVideo(file: File) {
        val intent = Intent(this, VideoPlayerActivity::class.java).apply {
            data = Uri.fromFile(file)
        }
        startActivity(intent)
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.directory_browser_menu, menu)
        
        val searchItem = menu?.findItem(R.id.action_search)
        val searchView = searchItem?.actionView as? SearchView
        
        searchView?.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean {
                return false
            }
            
            override fun onQueryTextChange(newText: String?): Boolean {
                filterFiles(newText ?: "")
                return true
            }
        })
        
        return true
    }
    
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                if (isShowingMediaFiles) {
                    finish()
                } else if (currentDirectory.parent != null) {
                    loadDirectory(File(currentDirectory.parent!!))
                } else {
                    loadMediaFiles()
                }
                true
            }
            R.id.action_toggle_view -> {
                isGridView = !isGridView
                updateLayoutManager()
                item.setIcon(if (isGridView) R.drawable.ic_view_list else R.drawable.ic_view_grid)
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
    
    private fun filterFiles(query: String) {
        val filteredItems = if (query.isEmpty()) {
            allFiles
        } else {
            allFiles.filter { item ->
                item.displayName.contains(query, ignoreCase = true)
            }
        }
        adapter.updateItems(filteredItems)
    }
    
    override fun onBackPressed() {
        if (isShowingMediaFiles) {
            super.onBackPressed()
        } else if (currentDirectory.parent != null) {
            loadDirectory(File(currentDirectory.parent!!))
        } else {
            loadMediaFiles()
        }
    }
}

data class FileItem(
    val file: File,
    val displayName: String,
    val isDirectory: Boolean,
    val isParentDirectory: Boolean = false
)