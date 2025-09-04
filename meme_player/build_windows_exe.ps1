# Script để tạo file .exe cho ứng dụng Meme Player

# Đường dẫn thư mục gốc của dự án
$projectRoot = "d:\desktop\Meme Player\meme_player"

# Di chuyển đến thư mục dự án
Set-Location -Path $projectRoot

# Cập nhật các phụ thuộc
Write-Host "Đang cập nhật các phụ thuộc..."
flutter pub get

# Tạo file .exe cho Windows
Write-Host "Đang tạo file .exe cho Windows..."
flutter build windows --release

# Kiểm tra xem file .exe đã được tạo thành công chưa
$exePath = Join-Path $projectRoot "build\windows\runner\Release\meme_player.exe"
if (Test-Path $exePath) {
    Write-Host "Đã tạo thành công file .exe tại: $exePath"
    
    # Tạo thư mục để chứa file .exe và các tài nguyên cần thiết
    $releaseDir = Join-Path $projectRoot "release"
    if (-not (Test-Path $releaseDir)) {
        New-Item -Path $releaseDir -ItemType Directory -Force
    }
    
    # Sao chép file .exe và các tài nguyên cần thiết vào thư mục release
    $releaseFiles = Join-Path $projectRoot "build\windows\runner\Release\*"
    Copy-Item -Path $releaseFiles -Destination $releaseDir -Recurse -Force
    
    Write-Host "Đã sao chép các file cần thiết vào thư mục: $releaseDir"
    Write-Host "Bạn có thể chạy ứng dụng từ file: $(Join-Path $releaseDir "meme_player.exe")"
} else {
    Write-Host "Không thể tạo file .exe. Vui lòng kiểm tra lỗi trong quá trình build."
}