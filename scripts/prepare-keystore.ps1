# Tauri WebView Android 应用 Keystore 准备脚本 (Windows)

# 检查环境变量
if (-not $env:ANDROID_KEYSTORE_BASE64) {
    Write-Host "错误: 未设置 ANDROID_KEYSTORE_BASE64 环境变量" -ForegroundColor Red
    exit 1
}

if (-not $env:KEYSTORE_PASSWORD) {
    Write-Host "错误: 未设置 KEYSTORE_PASSWORD 环境变量" -ForegroundColor Red
    exit 1
}

if (-not $env:KEY_ALIAS) {
    Write-Host "错误: 未设置 KEY_ALIAS 环境变量" -ForegroundColor Red
    exit 1
}

if (-not $env:KEY_PASSWORD) {
    Write-Host "错误: 未设置 KEY_PASSWORD 环境变量" -ForegroundColor Red
    exit 1
}

# 创建 android 目录（如果不存在）
if (-not (Test-Path -Path "android")) {
    New-Item -ItemType Directory -Path "android" | Out-Null
}

# 解码 Base64 编码的 Keystore 文件
Write-Host "解码 Keystore 文件..." -ForegroundColor Cyan
$keystorePath = "android/keystore.jks"

try {
    $bytes = [Convert]::FromBase64String($env:ANDROID_KEYSTORE_BASE64)
    [IO.File]::WriteAllBytes($keystorePath, $bytes)
    Write-Host "Keystore 文件已保存到 $keystorePath" -ForegroundColor Green
} catch {
    Write-Host "错误: Keystore 解码失败 - $_" -ForegroundColor Red
    exit 1
}

# 创建 keystore.properties 文件
Write-Host "创建 keystore.properties 文件..." -ForegroundColor Cyan
$propertiesPath = "android/keystore.properties"

$propertiesContent = @"
storeFile=keystore.jks
storePassword=$($env:KEYSTORE_PASSWORD)
keyAlias=$($env:KEY_ALIAS)
keyPassword=$($env:KEY_PASSWORD)
"@

try {
    Set-Content -Path $propertiesPath -Value $propertiesContent
    Write-Host "keystore.properties 文件已创建" -ForegroundColor Green
} catch {
    Write-Host "错误: keystore.properties 创建失败 - $_" -ForegroundColor Red
    exit 1
}

Write-Host "Keystore 准备完成" -ForegroundColor Green
exit 0