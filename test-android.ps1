# 安卓应用测试脚本
# 此脚本用于测试TenRun WebView安卓应用的功能

# 检查环境
function Check-Environment {
    Write-Host "检查测试环境..." -ForegroundColor Cyan
    
    # 检查Android SDK是否安装
    $adb = Get-Command adb -ErrorAction SilentlyContinue
    if (-not $adb) {
        Write-Host "错误: 未找到adb命令，请确保Android SDK已安装并添加到PATH中" -ForegroundColor Red
        return $false
    }
    
    # 检查是否有设备连接
    $devices = & adb devices
    if ($devices -match "no devices") {
        Write-Host "错误: 未检测到Android设备，请连接设备或启动模拟器" -ForegroundColor Red
        return $false
    }
    
    Write-Host "环境检查通过" -ForegroundColor Green
    return $true
}

# 安装APK
function Install-App {
    param (
        [string]$ApkPath
    )
    
    if (-not (Test-Path $ApkPath)) {
        Write-Host "错误: APK文件不存在: $ApkPath" -ForegroundColor Red
        return $false
    }
    
    Write-Host "正在安装APK: $ApkPath" -ForegroundColor Cyan
    & adb install -r $ApkPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "安装失败" -ForegroundColor Red
        return $false
    }
    
    Write-Host "APK安装成功" -ForegroundColor Green
    return $true
}

# 启动应用
function Start-App {
    param (
        [string]$PackageName
    )
    
    Write-Host "启动应用: $PackageName" -ForegroundColor Cyan
    & adb shell monkey -p $PackageName -c android.intent.category.LAUNCHER 1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "应用启动失败" -ForegroundColor Red
        return $false
    }
    
    Write-Host "应用启动成功" -ForegroundColor Green
    return $true
}

# 检查应用是否在运行
function Check-AppRunning {
    param (
        [string]$PackageName
    )
    
    $processInfo = & adb shell "ps | grep $PackageName"
    return $processInfo -match $PackageName
}

# 测试WebView加载
function Test-WebViewLoading {
    param (
        [string]$PackageName
    )
    
    Write-Host "测试WebView加载..." -ForegroundColor Cyan
    
    # 等待应用完全启动
    Start-Sleep -Seconds 3
    
    # 检查应用是否崩溃
    if (-not (Check-AppRunning -PackageName $PackageName)) {
        Write-Host "错误: 应用已崩溃" -ForegroundColor Red
        return $false
    }
    
    # 检查WebView是否加载
    $logcat = & adb logcat -d | Select-String "WebView"
    if ($logcat -match "WebView.*error") {
        Write-Host "WebView加载出现错误" -ForegroundColor Red
        return $false
    }
    
    Write-Host "WebView加载测试通过" -ForegroundColor Green
    return $true
}

# 测试URL导航
function Test-Navigation {
    Write-Host "测试URL导航功能..." -ForegroundColor Cyan
    
    # 清除日志
    & adb logcat -c
    
    # 模拟点击URL输入框
    & adb shell input tap 500 100
    Start-Sleep -Seconds 1
    
    # 输入URL
    & adb shell input text "https://www.baidu.com"
    Start-Sleep -Seconds 1
    
    # 模拟点击Go按钮
    & adb shell input tap 900 100
    Start-Sleep -Seconds 5
    
    # 检查是否成功加载
    $logcat = & adb logcat -d | Select-String "baidu"
    if (-not $logcat) {
        Write-Host "URL导航测试失败" -ForegroundColor Red
        return $false
    }
    
    Write-Host "URL导航测试通过" -ForegroundColor Green
    return $true
}

# 测试返回按钮
function Test-BackButton {
    Write-Host "测试返回按钮功能..." -ForegroundColor Cyan
    
    # 清除日志
    & adb logcat -c
    
    # 模拟点击返回按钮
    & adb shell input keyevent 4
    Start-Sleep -Seconds 2
    
    # 检查是否有返回操作的日志
    $logcat = & adb logcat -d | Select-String "goBack"
    if (-not $logcat) {
        Write-Host "返回按钮测试失败" -ForegroundColor Red
        return $false
    }
    
    Write-Host "返回按钮测试通过" -ForegroundColor Green
    return $true
}

# 卸载应用
function Uninstall-App {
    param (
        [string]$PackageName
    )
    
    Write-Host "卸载应用: $PackageName" -ForegroundColor Cyan
    & adb uninstall $PackageName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "应用卸载失败" -ForegroundColor Red
        return $false
    }
    
    Write-Host "应用卸载成功" -ForegroundColor Green
    return $true
}

# 主测试流程
function Run-Tests {
    param (
        [string]$ApkPath,
        [string]$PackageName
    )
    
    Write-Host "===== 开始测试 TenRun WebView 安卓应用 =====" -ForegroundColor Yellow
    
    # 检查环境
    if (-not (Check-Environment)) {
        return $false
    }
    
    # 安装APK
    if (-not (Install-App -ApkPath $ApkPath)) {
        return $false
    }
    
    # 启动应用
    if (-not (Start-App -PackageName $PackageName)) {
        return $false
    }
    
    # 测试WebView加载
    if (-not (Test-WebViewLoading -PackageName $PackageName)) {
        return $false
    }
    
    # 测试URL导航
    if (-not (Test-Navigation)) {
        return $false
    }
    
    # 测试返回按钮
    if (-not (Test-BackButton)) {
        return $false
    }
    
    # 测试完成，卸载应用
    if (-not (Uninstall-App -PackageName $PackageName)) {
        return $false
    }
    
    Write-Host "===== 所有测试通过 =====" -ForegroundColor Green
    return $true
}

# 查找最新的APK文件
function Find-LatestApk {
    $apkFiles = Get-ChildItem -Path "$PSScriptRoot\dist" -Filter "*.apk" -ErrorAction SilentlyContinue
    if (-not $apkFiles) {
        $apkFiles = Get-ChildItem -Path "$PSScriptRoot\android\app\build\outputs\apk\release" -Filter "*.apk" -ErrorAction SilentlyContinue
    }
    
    if (-not $apkFiles) {
        return $null
    }
    
    return $apkFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
}

# 主函数
function Main {
    # 应用包名
    $packageName = "com.tenrun.webview"
    
    # 查找APK文件
    $apkPath = Find-LatestApk
    if (-not $apkPath) {
        Write-Host "错误: 未找到APK文件，请先构建应用" -ForegroundColor Red
        return
    }
    
    Write-Host "找到APK文件: $apkPath" -ForegroundColor Cyan
    
    # 运行测试
    $result = Run-Tests -ApkPath $apkPath -PackageName $packageName
    
    if ($result) {
        Write-Host "测试完成: 所有测试通过" -ForegroundColor Green
    } else {
        Write-Host "测试完成: 存在失败的测试" -ForegroundColor Red
    }
}

# 执行主函数
Main