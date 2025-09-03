@echo off
setlocal enabledelayedexpansion

:: Tauri WebView Android 应用本地构建脚本 (Windows)
:: 用法: build-local.bat [debug|release]

:: 默认构建类型
set BUILD_TYPE=debug
if "%1"=="release" set BUILD_TYPE=release

echo 开始构建 Android APK (类型: %BUILD_TYPE%)

:: 检查环境变量
if "%BUILD_TYPE%"=="release" (
    if "%KEYSTORE_PASSWORD%"=="" (
        echo 警告: 未设置 KEYSTORE_PASSWORD 环境变量，这在 release 构建中是必需的
        echo 您可以设置以下环境变量:
        echo   KEYSTORE_PASSWORD - Keystore 密码
        echo   KEY_ALIAS - 密钥别名
        echo   KEY_PASSWORD - 密钥密码
        echo   ANDROID_KEYSTORE_BASE64 - Base64 编码的 keystore 文件
    )
)

:: 检查应用配置环境变量
if "%APP_NAME%"=="" echo 警告: 未设置 APP_NAME 环境变量，将使用默认值
if "%BUNDLE_ID%"=="" echo 警告: 未设置 BUNDLE_ID 环境变量，将使用默认值
if "%APP_VERSION%"=="" echo 警告: 未设置 APP_VERSION 环境变量，将使用默认值
if "%REMOTE_URL%"=="" echo 警告: 未设置 REMOTE_URL 环境变量，将使用默认值

:: 准备 Keystore (仅限 release 构建)
if "%BUILD_TYPE%"=="release" (
    if not "%ANDROID_KEYSTORE_BASE64%"=="" (
        echo 准备 Keystore...
        powershell -Command "scripts\prepare-keystore.ps1"
        if !ERRORLEVEL! neq 0 (
            echo 错误: Keystore 准备失败
            exit /b 1
        )
    )
)

:: 构建前端
echo 构建前端...
call npm run build
if %ERRORLEVEL% neq 0 (
    echo 错误: 前端构建失败
    exit /b 1
)

:: 检查 Tauri CLI
echo 检查 Tauri CLI...
call npx tauri --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo 安装 Tauri CLI...
    call npm install -g @tauri-apps/cli
    if !ERRORLEVEL! neq 0 (
        echo 错误: Tauri CLI 安装失败
        exit /b 1
    )
)

:: 初始化 Android 平台 (如果需要)
if not exist "android\app\src\main\java\com\tauri\webview" (
    echo 初始化 Android 平台...
    call npm run tauri:android:init
    if !ERRORLEVEL! neq 0 (
        echo 错误: Android 平台初始化失败
        exit /b 1
    )
)

:: 构建 Android APK
echo 构建 Android APK (%BUILD_TYPE%)...
if "%BUILD_TYPE%"=="debug" (
    call npm run tauri:android:dev
) else (
    call npm run tauri:android:build
)

if %ERRORLEVEL% neq 0 (
    echo 错误: Android APK 构建失败
    exit /b 1
)

:: 显示输出路径
if "%BUILD_TYPE%"=="debug" (
    echo APK 构建成功! 输出路径:
    echo src-tauri\gen\android\app\build\outputs\debug\app-debug.apk
) else (
    echo APK 构建成功! 输出路径:
    echo src-tauri\gen\android\app\build\outputs\release\app-release.apk
)

endlocal