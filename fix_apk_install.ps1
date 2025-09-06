# Fix APK Installation Issues - Meme Player
# Say hi ANCNT!

Write-Host "Chan doan va sua loi cai dat APK Meme Player..." -ForegroundColor Green

# Kiem tra APK co ton tai khong
$apkPath = "memeplayer.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "Khong tim thay file memeplayer.apk" -ForegroundColor Red
    Write-Host "Vui long chay build_apk.ps1 truoc" -ForegroundColor Yellow
    exit 1
}

Write-Host "Tim thay file APK: $apkPath" -ForegroundColor Green

# Kiem tra kich thuoc APK
$apkSize = (Get-Item $apkPath).Length / 1MB
Write-Host "Kich thuoc APK: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan

if ($apkSize -lt 5) {
    Write-Host "APK co ve nho bat thuong, co the bi loi build" -ForegroundColor Yellow
}

# Tao APK da ky (signed) de tranh loi cai dat
Write-Host "`nTao APK da ky de tranh loi cai dat..." -ForegroundColor Yellow

# Navigate to mobile app directory
Set-Location "mobile_app"

# Tao debug keystore neu chua co
$keystorePath = "debug.keystore"
if (-not (Test-Path $keystorePath)) {
    Write-Host "Tao debug keystore..." -ForegroundColor Yellow
    & keytool -genkey -v -keystore $keystorePath -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
}

# Build signed debug APK
Write-Host "Build APK da ky..." -ForegroundColor Yellow
.\gradlew assembleDebug

# Kiem tra APK debug
$debugApkPath = "app\build\outputs\apk\debug\app-debug.apk"
if (Test-Path $debugApkPath) {
    Write-Host "APK debug da ky duoc tao thanh cong" -ForegroundColor Green
    
    # Copy APK debug ra thu muc goc
    Copy-Item $debugApkPath "..\memeplayer-debug.apk" -Force
    Write-Host "APK debug da copy: memeplayer-debug.apk" -ForegroundColor Green
} else {
    Write-Host "Khong the tao APK debug" -ForegroundColor Red
}

# Quay lai thu muc goc
Set-Location ".."

Write-Host "`nHUONG DAN SUA LOI CAI DAT:" -ForegroundColor Cyan
Write-Host "`n1. LOI 'App not installed' hoac 'Parse error':" -ForegroundColor White
Write-Host "   - Su dung file memeplayer-debug.apk thay vi memeplayer.apk" -ForegroundColor Gray
Write-Host "   - Bat 'Unknown sources' trong Settings > Security" -ForegroundColor Gray
Write-Host "   - Bat 'Install unknown apps' cho file manager" -ForegroundColor Gray

Write-Host "`n2. LOI 'Signature verification failed':" -ForegroundColor White
Write-Host "   - Go cai dat phien ban cu truoc khi cai moi" -ForegroundColor Gray
Write-Host "   - Xoa cache cua Package Installer" -ForegroundColor Gray

Write-Host "`n3. LOI 'Insufficient storage':" -ForegroundColor White
Write-Host "   - Giai phong it nhat 50MB dung luong" -ForegroundColor Gray
Write-Host "   - Xoa cache cac ung dung khong can thiet" -ForegroundColor Gray

Write-Host "`n4. LOI 'App conflicts with existing package':" -ForegroundColor White
Write-Host "   - Go cai dat ung dung co cung package name" -ForegroundColor Gray
Write-Host "   - Restart dien thoai va thu lai" -ForegroundColor Gray

Write-Host "`n5. ANDROID 13+ (API 33+):" -ForegroundColor White
Write-Host "   - Cap quyen 'Install unknown apps' cho tung ung dung" -ForegroundColor Gray
Write-Host "   - Vao Settings > Apps > Special access > Install unknown apps" -ForegroundColor Gray

Write-Host "`nCACH CAI DAT AN TOAN:" -ForegroundColor Green
Write-Host "1. Copy file memeplayer-debug.apk vao dien thoai" -ForegroundColor White
Write-Host "2. Mo file bang File Manager" -ForegroundColor White
Write-Host "3. Cho phep cai dat tu nguon khong xac dinh" -ForegroundColor White
Write-Host "4. Nhan Install va doi hoan tat" -ForegroundColor White

Write-Host "`nHoan tat chan doan va tao APK cai dat an toan!" -ForegroundColor Green
Write-Host "Files co san:" -ForegroundColor Cyan
if (Test-Path "memeplayer.apk") {
    Write-Host "   - memeplayer.apk (release)" -ForegroundColor Gray
}
if (Test-Path "memeplayer-debug.apk") {
    Write-Host "   - memeplayer-debug.apk (debug - khuyen nghi)" -ForegroundColor Gray
}