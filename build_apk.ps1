# Build APK script for Meme Player
# Say hi ANCNT!

Write-Host "Building Meme Player APK..." -ForegroundColor Green

# Navigate to mobile app directory
Set-Location "d:\desktop\Meme Player\mobile_app"

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
.\gradlew clean

# Build release APK
Write-Host "Building release APK..." -ForegroundColor Yellow
.\gradlew assembleRelease

# Check if APK was built successfully
$apkPath = "app\build\outputs\apk\release\app-release.apk"
if (Test-Path $apkPath) {
    Write-Host "APK built successfully!" -ForegroundColor Green
    
    # Copy APK to root directory with custom name
    $destinationPath = "..\memeplayer.apk"
    Copy-Item $apkPath $destinationPath -Force
    
    Write-Host "APK copied to: $destinationPath" -ForegroundColor Green
    Write-Host "Build completed successfully!" -ForegroundColor Green
} else {
    Write-Host "APK build failed! APK file not found at: $apkPath" -ForegroundColor Red
    Write-Host "Checking alternative paths..." -ForegroundColor Yellow
    
    # Check alternative paths
    $altPaths = @(
        "app\build\outputs\apk\release\app-release-unsigned.apk",
        "app\build\outputs\apk\debug\app-debug.apk"
    )
    
    foreach ($altPath in $altPaths) {
        if (Test-Path $altPath) {
            Write-Host "Found APK at: $altPath" -ForegroundColor Yellow
            $destinationPath = "..\memeplayer.apk"
            Copy-Item $altPath $destinationPath -Force
            Write-Host "APK copied to: $destinationPath" -ForegroundColor Green
            break
        }
    }
}

# Return to original directory
Set-Location ".."

Write-Host "Script completed!" -ForegroundColor Cyan