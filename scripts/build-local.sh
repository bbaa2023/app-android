#!/bin/bash

# 脚本：build-local.sh
# 用途：本地构建Android APK
# 使用方法：./build-local.sh [debug|release]

set -e

# 加载.env.local文件（如果存在）
if [ -f "../.env.local" ]; then
  echo "加载.env.local环境变量..."
  export $(grep -v '^#' ../.env.local | xargs -d '\n')
fi

# 默认构建类型
BUILD_TYPE="debug"

# 包名检测与自动重建机制
detect_and_rebuild() {
  echo "检查包名配置一致性..."
  
  # 获取.env.local中的BUNDLE_ID
  ENV_BUNDLE_ID=${BUNDLE_ID:-"com.tenrun.webview"}
  
  # 获取tauri.conf.json中的identifier
  TAURI_IDENTIFIER=$(grep -oP '(?<="identifier": ")[^"]+' ../src-tauri/tauri.conf.json || echo "com.tenrun.webview")
  
  echo "- .env.local中的BUNDLE_ID: $ENV_BUNDLE_ID"
  echo "- tauri.conf.json中的identifier: $TAURI_IDENTIFIER"
  
  # 检查是否需要重建
  if [ "$ENV_BUNDLE_ID" != "$TAURI_IDENTIFIER" ]; then
    echo "警告：包名配置不一致！需要重建Android项目。"
    
    # 删除旧的Android生成目录
    if [ -d "../src-tauri/gen/android" ]; then
      echo "删除旧的Android生成目录..."
      rm -rf ../src-tauri/gen/android
    fi
    
    echo "注意：Android项目将在构建过程中自动重建。"
  fi
}

# 运行包名检测
urgent_rebuild=false
if [ -d "../src-tauri/gen/android" ]; then
  detect_and_rebuild
fi

# 检查参数
if [ "$1" = "release" ]; then
  BUILD_TYPE="release"
  echo "构建类型：Release"
else
  echo "构建类型：Debug (默认)"
  echo "提示：使用 './build-local.sh release' 进行Release构建"
fi

# 检查环境变量
if [ "$BUILD_TYPE" = "release" ]; then
  if [ -z "$ANDROID_KEYSTORE_BASE64" ]; then
    echo "警告：环境变量ANDROID_KEYSTORE_BASE64未设置，将使用开发密钥"
  fi

  if [ -z "$KEYSTORE_PASSWORD" ]; then
    echo "警告：环境变量KEYSTORE_PASSWORD未设置，将使用开发密钥"
  fi

  if [ -z "$KEY_ALIAS" ]; then
    echo "警告：环境变量KEY_ALIAS未设置，将使用开发密钥"
  fi

  if [ -z "$KEY_PASSWORD" ]; then
    echo "警告：环境变量KEY_PASSWORD未设置，将使用开发密钥"
  fi
fi

# 检查必要的环境变量
if [ -z "$APP_NAME" ]; then
  echo "警告：环境变量APP_NAME未设置，将使用默认值"
fi

if [ -z "$BUNDLE_ID" ]; then
  echo "警告：环境变量BUNDLE_ID未设置，将使用默认值"
fi

if [ -z "$APP_VERSION" ]; then
  echo "警告：环境变量APP_VERSION未设置，将使用默认值"
fi

if [ -z "$REMOTE_URL" ] && [ -z "$APP_REMOTE_URL" ]; then
  echo "警告：环境变量REMOTE_URL和APP_REMOTE_URL均未设置，将使用默认URL"
fi

# 准备keystore（仅release构建）
if [ "$BUILD_TYPE" = "release" ] && [ ! -z "$ANDROID_KEYSTORE_BASE64" ]; then
  echo "准备keystore..."
  ./scripts/prepare-keystore.sh
fi

# 构建前端
echo "构建前端..."
npm run build

# 确保Tauri CLI已安装
if ! command -v tauri &> /dev/null; then
  echo "安装Tauri CLI..."
  npm install -g @tauri-apps/cli
fi

# 初始化Android平台（如果需要）
if [ ! -d "src-tauri/gen/android" ]; then
  echo "初始化Android平台..."
  npm run tauri android init
fi

# 构建Android APK
echo "构建Android APK (${BUILD_TYPE})..."
if [ "$BUILD_TYPE" = "release" ]; then
  npm run tauri android build
else
  npm run tauri android build -- --debug
fi

# 显示APK路径
if [ "$BUILD_TYPE" = "release" ]; then
  APK_PATH="src-tauri/gen/android/app/build/outputs/apk/release/app-release.apk"
else
  APK_PATH="src-tauri/gen/android/app/build/outputs/apk/debug/app-debug.apk"
fi

if [ -f "$APK_PATH" ]; then
  echo "构建成功！APK位置：$APK_PATH"
else
  echo "构建失败，未找到APK文件"
  exit 1
fi