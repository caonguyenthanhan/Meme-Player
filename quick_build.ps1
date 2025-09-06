# Quick Build Script - Chỉ build debug APK nhanh
# Script build nhanh chỉ APK debug với timestamp

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Write-Host "=== QUICK BUILD - DEBUG APK ===" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor Yellow

$projectRoot = "d:\desktop\Meme Player"
$mobileAppPath = "$projectRoot\mobile_app"

Set-Location $mobileAppPath

# Build debug APK
Write-Host "Building debug APK..." -ForegroundColor Yellow
.\gradlew assembleDebug

if ($LASTEXITCODE -eq 0) {
    # Copy APK
    $debugApkPath = "$mobileAppPath\app\build\outputs\apk\debug\app-debug.apk"
    if (Test-Path $debugApkPath) {
        $outputName = "memeplayer-debug-$timestamp.apk"
        Copy-Item $debugApkPath "$projectRoot\$outputName" -Force
        
        # Update latest
        $latestPath = "$projectRoot\memeplayer-debug-latest.apk"
        if (Test-Path $latestPath) { Remove-Item $latestPath -Force }
        Copy-Item "$projectRoot\$outputName" $latestPath -Force
        
        Write-Host "✓ APK ready: $outputName" -ForegroundColor Green
        Write-Host "✓ Latest: memeplayer-debug-latest.apk" -ForegroundColor Green
    }
} else {
    Write-Host "✗ Build failed!" -ForegroundColor Red
}

Set-Location $projectRoot