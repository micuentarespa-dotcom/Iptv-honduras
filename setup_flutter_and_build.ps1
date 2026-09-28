# Script de Instalación Rápida de Flutter SDK y Compilador de APK para Windows
Write-Host "🚀 Iniciando configuración de Flutter SDK para IPTV Honduras..." -ForegroundColor Cyan

$flutterDir = "C:\src\flutter"
$zipPath = "$env:TEMP\flutter_windows.zip"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.6-stable.zip"

if (-not (Test-Path "$flutterDir\bin\flutter.bat")) {
    Write-Host "📦 Descargando Flutter SDK (esto puede tomar un par de minutos)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $flutterUrl -OutFile $zipPath
    
    Write-Host "📂 Extrayendo Flutter SDK en $flutterDir..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "C:\src" | Out-Null
    Expand-Archive -Path $zipPath -DestinationPath "C:\src" -Force
    Remove-Item $zipPath
}

# Agregar Flutter al PATH temporal de la sesión
$env:Path += ";$flutterDir\bin"

Write-Host "⚡ Ejecutando 'flutter pub get'..." -ForegroundColor Green
Set-Location "C:\Users\M6600\.gemini\antigravity\scratch\iptv-honduras-flutter_app"
& "$flutterDir\bin\flutter.bat" pub get

Write-Host "🔨 Compilando APK Release para Android..." -ForegroundColor Green
& "$flutterDir\bin\flutter.bat" build apk --release

Write-Host "✅ ¡Compilación Completada!" -ForegroundColor Green
Write-Host "📍 Tu archivo APK listo para instalar en Android se encuentra en:" -ForegroundColor Cyan
Write-Host "   C:\Users\M6600\.gemini\antigravity\scratch\iptv-honduras-flutter_app\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
