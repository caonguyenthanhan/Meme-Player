# Script để tạo thư mục meme_plugin và di chuyển các file plugin vào đó

# Đường dẫn thư mục gốc của dự án
$projectRoot = "d:\desktop\Meme Player\meme_player"

# Tạo thư mục meme_plugin nếu chưa tồn tại
$memePluginDir = Join-Path $projectRoot "lib\meme_plugin"
if (-not (Test-Path $memePluginDir)) {
    New-Item -Path $memePluginDir -ItemType Directory -Force
    Write-Host "Đã tạo thư mục $memePluginDir"
}

# Di chuyển các file plugin vào thư mục meme_plugin
$pluginsDir = Join-Path $projectRoot "lib\plugins"
$pluginFiles = Get-ChildItem -Path $pluginsDir -Filter "*.dart"

foreach ($file in $pluginFiles) {
    $destinationPath = Join-Path $memePluginDir $file.Name
    Copy-Item -Path $file.FullName -Destination $destinationPath -Force
    Write-Host "Đã sao chép $($file.Name) vào thư mục meme_plugin"
}

Write-Host "Hoàn tất! Tất cả các file plugin đã được sao chép vào thư mục meme_plugin."