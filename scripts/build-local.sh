#!/bin/bash

# 脚本：build-local.sh
# 用途：本地构建Android APK
# 使用方法：./build-local.sh [debug|release]

# 设置严格模式，出错即退出
source="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(dirname "$source")"

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 错误处理函数
error_exit() {
  echo -e "${RED}错误: $1${NC}"
  echo "构建失败，请检查上述错误信息"
  exit 1
}

# 警告函数
warning() {
  echo -e "${YELLOW}警告: $1${NC}"
}

# 信息函数
info() {
  echo -e "${BLUE}信息: $1${NC}"
}

# 成功函数
success() {
  echo -e "${GREEN}成功: $1${NC}"
}

# 检查命令是否存在
check_command() {
  if ! command -v "$1" &> /dev/null; then
    error_exit "命令 '$1' 未找到，请先安装"
  fi
}

# 加载.env.local文件（如果存在）
load_env() {
  if [ -f "$root_dir/.env.local" ]; then
    info "加载.env.local环境变量..."
    export $(grep -v '^#' "$root_dir/.env.local" | xargs -d '\n' || true)
    if [ $? -ne 0 ]; then
      warning "环境变量加载可能不完整，请检查.env.local格式"
    fi
  else
    warning "未找到.env.local文件，将使用默认配置或系统环境变量"
  fi
}

# 检查环境依赖
check_dependencies() {
  info "检查环境依赖..."
  check_command "node"
  check_command "npm"
  check_command "cargo"
  check_command "rustc"
  
  # 检查Rust版本
  rust_version=$(rustc --version | cut -d' ' -f2)
  required_rust_version="1.60"
  if [ "$(printf "%s\n%s" "$required_rust_version" "$rust_version" | sort -V | head -n1)" != "$required_rust_version" ]; then
    warning "Rust版本 $rust_version 低于建议的 $required_rust_version"
  fi
  
  # 检查Node.js版本
  node_version=$(node --version | cut -d'v' -f2)
  required_node_version="16"
  if [ "$(printf "%s\n%s" "$required_node_version" "$node_version" | sort -V | head -n1)" != "$required_node_version" ]; then
    warning "Node.js版本 $node_version 低于建议的 $required_node_version"
  fi
  
  # 检查Android SDK
  if [ -z "$ANDROID_HOME" ]; then
    warning "ANDROID_HOME环境变量未设置，可能需要手动配置"
  fi
}

# 包名检测与自动重建机制
detect_and_rebuild() {
  info "检查包名配置一致性..."
  
  # 获取.env.local中的BUNDLE_ID
  ENV_BUNDLE_ID=${BUNDLE_ID:-"com.tenrun.webview"}
  
  # 获取tauri.conf.json中的identifier
  TAURI_IDENTIFIER=$(grep -oP '(?<="identifier": ")[^"]+' "$root_dir/src-tauri/tauri.conf.json" || echo "com.tenrun.webview")
  
  echo "- .env.local中的BUNDLE_ID: $ENV_BUNDLE_ID"
  echo "- tauri.conf.json中的identifier: $TAURI_IDENTIFIER"
  
  # 检查是否需要重建
  if [ "$ENV_BUNDLE_ID" != "$TAURI_IDENTIFIER" ]; then
    warning "包名配置不一致！需要重建Android项目。"
    
    # 删除旧的Android生成目录
    if [ -d "$root_dir/src-tauri/gen/android" ]; then
      info "删除旧的Android生成目录..."
      rm -rf "$root_dir/src-tauri/gen/android" || error_exit "无法删除旧的Android生成目录"
    fi
    
    echo "注意：Android项目将在构建过程中自动重建。"
  fi
}

# 构建前端
build_frontend() {
  info "构建前端..."
  cd "$root_dir" && npm run build || error_exit "前端构建失败"
}

# 安装并检查Tauri CLI
install_tauri_cli() {
  if ! command -v tauri &> /dev/null; then
    info "安装Tauri CLI..."
    npm install -g @tauri-apps/cli || error_exit "Tauri CLI安装失败"
  else
    info "Tauri CLI已安装"
  fi
}

# 初始化Android平台
init_android_platform() {
  if [ ! -d "$root_dir/src-tauri/gen/android" ]; then
    info "初始化Android平台..."
    cd "$root_dir" && npm run tauri:android:init || error_exit "Android平台初始化失败"
  else
    info "Android平台已初始化，跳过此步骤"
  fi
}

# 构建Android APK
build_android_apk() {
  info "构建Android APK (${BUILD_TYPE})..."
  cd "$root_dir"
  if [ "$BUILD_TYPE" = "release" ]; then
    npm run tauri:android:build || error_exit "Release APK构建失败"
  else
    npm run tauri:android:build:debug || error_exit "Debug APK构建失败"
  fi
}

# 验证APK是否生成
verify_apk() {
  cd "$root_dir"
  if [ "$BUILD_TYPE" = "release" ]; then
    APK_PATH="src-tauri/gen/android/app/build/outputs/apk/release/app-release.apk"
  else
    APK_PATH="src-tauri/gen/android/app/build/outputs/apk/debug/app-debug.apk"
  fi
  
  if [ -f "$APK_PATH" ]; then
    success "构建成功！APK位置：$APK_PATH"
    echo "构建类型: $BUILD_TYPE"
    echo "应用包名: $(grep -oP '(?<="identifier": ")[^"]+' "src-tauri/tauri.conf.json")"
    echo "应用版本: $(grep -oP '(?<="version": ")[^"]+' "src-tauri/tauri.conf.json")"
  else
    error_exit "构建失败，未找到APK文件。路径：$APK_PATH"
  fi
}

# 主函数
main() {
  # 设置默认构建类型
  BUILD_TYPE="debug"
  
  # 检查参数
  if [ "$1" = "release" ]; then
    BUILD_TYPE="release"
    info "构建类型：Release"
  else
    info "构建类型：Debug (默认)"
    info "提示：使用 './build-local.sh release' 进行Release构建"
  fi
  
  # 加载环境变量
  load_env
  
  # 检查环境依赖
  check_dependencies
  
  # 检查包名配置
  if [ -d "$root_dir/src-tauri/gen/android" ]; then
    detect_and_rebuild
  fi
  
  # 检查必要的环境变量
  if [ -z "$APP_NAME" ]; then
    warning "环境变量APP_NAME未设置，将使用默认值"
  fi
  
  if [ -z "$BUNDLE_ID" ]; then
    warning "环境变量BUNDLE_ID未设置，将使用默认值"
  fi
  
  if [ -z "$APP_VERSION" ]; then
    warning "环境变量APP_VERSION未设置，将使用默认值"
  fi
  
  if [ -z "$REMOTE_URL" ] && [ -z "$DEFAULT_URL" ]; then
    warning "环境变量REMOTE_URL和DEFAULT_URL均未设置，将使用配置文件中的默认URL"
  fi
  
  # 准备keystore（仅release构建）
  if [ "$BUILD_TYPE" = "release" ] && [ ! -z "$ANDROID_KEYSTORE_BASE64" ]; then
    info "准备keystore..."
    cd "$root_dir" && ./scripts/prepare-keystore.sh || warning "keystore准备过程中出现问题，但将继续构建"
  fi
  
  # 执行构建流程
  build_frontend
  install_tauri_cli
  init_android_platform
  build_android_apk
  verify_apk
}

# 执行主函数
main "$@"