#!/bin/bash

# 脚本：prepare-keystore.sh
# 用途：解码base64编码的keystore并生成keystore.properties文件
# 使用方法：./prepare-keystore.sh

set -e

# 检查环境变量
if [ -z "$ANDROID_KEYSTORE_BASE64" ]; then
  echo "错误：环境变量ANDROID_KEYSTORE_BASE64未设置"
  echo "请设置ANDROID_KEYSTORE_BASE64环境变量为base64编码的keystore文件"
  exit 1
fi

if [ -z "$KEYSTORE_PASSWORD" ]; then
  echo "错误：环境变量KEYSTORE_PASSWORD未设置"
  exit 1
fi

if [ -z "$KEY_ALIAS" ]; then
  echo "错误：环境变量KEY_ALIAS未设置"
  exit 1
fi

if [ -z "$KEY_PASSWORD" ]; then
  echo "错误：环境变量KEY_PASSWORD未设置"
  exit 1
fi

# 确保android目录存在
if [ ! -d "android" ]; then
  echo "错误：android目录不存在"
  exit 1
fi

# 解码keystore
echo "正在解码keystore..."
echo "$ANDROID_KEYSTORE_BASE64" | base64 --decode > android/keystore.jks

if [ ! -f "android/keystore.jks" ]; then
  echo "错误：keystore解码失败"
  exit 1
fi

echo "keystore已成功解码到android/keystore.jks"

# 创建keystore.properties文件
echo "正在创建keystore.properties文件..."
cat > android/keystore.properties << EOF
storeFile=keystore.jks
storePassword=$KEYSTORE_PASSWORD
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASSWORD
EOF

echo "keystore.properties文件已创建"

echo "准备完成！"