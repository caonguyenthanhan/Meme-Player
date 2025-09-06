# Auto Build APK Script with Timestamp
# Script tu dong build APK va copy ra thu muc goc voi timestamp

# Thiet lap mau sac cho output
$Host.UI.RawUI.ForegroundColor = "Green"

# Lay thoi gian hien tai de danh dau
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$buildDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "=== MEME PLAYER AUTO BUILD SCRIPT ===" -ForegroundColor Cyan
Write-Host "Build started at: $buildDate" -ForegroundColor Yellow
Write-Host "Timestamp: $timestamp" -ForegroundColor Yellow
Write-Host ""

# Duong dan thu muc du an
$projectRoot = "d:\desktop\Meme Player"
$mobileAppPath = "$projectRoot\mobile_app"
$outputPath = $projectRoot

# Kiem tra thu muc mobile_app co ton tai khong
if (-not (Test-Path $mobileAppPath)) {
    Write-Host "ERROR: Mobile app directory not found at $mobileAppPath" -ForegroundColor Red
    exit 1
}

# Chuyen den thu muc mobile_app
Set-Location $mobileAppPath
Write-Host "Changed to directory: $mobileAppPath" -ForegroundColor Green

# Don dep build cu
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
try {
    .\gradlew clean
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Clean command failed, continuing anyway..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "WARNING: Clean command failed, continuing anyway..." -ForegroundColor Yellow
}

# Build APK debug
Write-Host "Building debug APK..." -ForegroundColor Yellow
try {
    .\gradlew assembleDebug
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Debug build failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Debug build failed!" -ForegroundColor Red
    exit 1
}

# Build APK release (neu co signing config)
Write-Host "Building release APK..." -ForegroundColor Yellow
try {
    .\gradlew assembleRelease
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Release build failed, using debug APK only" -ForegroundColor Yellow
        $releaseBuilt = $false
    } else {
        $releaseBuilt = $true
    }
} catch {
    Write-Host "WARNING: Release build failed, using debug APK only" -ForegroundColor Yellow
    $releaseBuilt = $false
}

# Tim va copy APK files
$debugApkPath = "$mobileAppPath\app\build\outputs\apk\debug\app-debug.apk"
$releaseApkPath = "$mobileAppPath\app\build\outputs\apk\release\app-release.apk"

# Copy debug APK
if (Test-Path $debugApkPath) {
    $debugOutputName = "memeplayer-debug-$timestamp.apk"
    $debugOutputPath = "$outputPath\$debugOutputName"
    Copy-Item $debugApkPath $debugOutputPath -Force
    Write-Host "Debug APK copied to: $debugOutputName" -ForegroundColor Green
    
    # Tao symlink cho APK debug moi nhat
    $latestDebugPath = "$outputPath\memeplayer-debug-latest.apk"
    if (Test-Path $latestDebugPath) {
        Remove-Item $latestDebugPath -Force
    }
    Copy-Item $debugOutputPath $latestDebugPath -Force
    Write-Host "Latest debug APK: memeplayer-debug-latest.apk" -ForegroundColor Green
} else {
    Write-Host "ERROR: Debug APK not found at $debugApkPath" -ForegroundColor Red
}

# Copy release APK (neu build thanh cong)
if ($releaseBuilt -and (Test-Path $releaseApkPath)) {
    $releaseOutputName = "memeplayer-release-$timestamp.apk"
    $releaseOutputPath = "$outputPath\$releaseOutputName"
    Copy-Item $releaseApkPath $releaseOutputPath -Force
    Write-Host "Release APK copied to: $releaseOutputName" -ForegroundColor Green
    
    # Tao symlink cho APK release moi nhat
    $latestReleasePath = "$outputPath\memeplayer-release-latest.apk"
    if (Test-Path $latestReleasePath) {
        Remove-Item $latestReleasePath -Force
    }
    Copy-Item $releaseOutputPath $latestReleasePath -Force
    Write-Host "Latest release APK: memeplayer-release-latest.apk" -ForegroundColor Green
}

# Hien thi thong tin APK
Write-Host ""
Write-Host "=== BUILD SUMMARY ===" -ForegroundColor Cyan
Write-Host "Build completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host "Build timestamp: $timestamp" -ForegroundColor Yellow

# Liet ke cac APK files trong thu muc goc
Write-Host ""
Write-Host "APK files in root directory:" -ForegroundColor Cyan
Get-ChildItem "$outputPath\*.apk" | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  $($_.Name) ($size MB)" -ForegroundColor White
}

Write-Host ""
Write-Host "Build process completed successfully!" -ForegroundColor Green
Write-Host "You can now install the APK files on your Android device." -ForegroundColor Yellow

# Quay ve thu muc goc
Set-Location $projectRoot

# Pause de xem ket qua
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')