# Tauri v2 WebView Android APK 打包项目

这个项目提供了一个完整的解决方案，用于将网页打包为Android APK应用。项目使用Tauri v2和WebView技术，并通过GitHub Actions实现云端自动打包和签名。

## 功能特点

- 使用Tauri v2框架，轻量级且高性能
- 支持加载远程URL或本地HTML页面
- 完整的Android WebView配置和优化
- 自动化GitHub Actions构建流程
- 安全的keystore管理和签名流程
- 详细的文档和指南

## 项目结构

```
├── .github/workflows/    # GitHub Actions工作流配置
├── android/              # Android项目文件
├── assets/               # 应用资源（图标、启动画面等）
├── docs/                 # 项目文档
├── scripts/              # 构建和工具脚本
├── src/                  # 前端源代码（可选）
├── src-tauri/            # Tauri配置和Rust代码
├── templates/            # 配置模板文件
├── .env.example          # 环境变量示例
└── README.md             # 项目说明文档
```

## 环境要求

### 开发环境

- [Node.js](https://nodejs.org/) 16+
- [Rust](https://www.rust-lang.org/) 1.60+
- [Tauri CLI](https://tauri.app/v1/guides/getting-started/prerequisites)
- [JDK 11](https://adoptium.net/) (Temurin/AdoptOpenJDK推荐)
- [Android SDK](https://developer.android.com/studio) 30+
- [Android NDK](https://developer.android.com/ndk) 25+

## 快速开始

### 本地开发

1. 克隆仓库

```bash
git clone https://github.com/yourusername/tauri-webview-android.git
cd tauri-webview-android
```

2. 安装依赖

```bash
npm install
```

3. 配置环境变量

复制`.env.example`文件为`.env.local`并填写必要的配置：

```bash
cp .env.example .env.local
# 编辑.env.local文件填写配置
```

4. 本地运行（开发模式）

```bash
npm run tauri dev
```

### 本地构建APK

使用提供的构建脚本：

```bash
# Windows
.\scripts\build-local.bat

# Linux/macOS
./scripts/build-local.sh
```

构建完成后，APK文件将位于`android/app/build/outputs/apk/`目录。

## GitHub Actions云端打包

本项目的GitHub Actions工作流已完全配置好Rust环境和Android构建工具链，您无需在本地安装Rust环境即可实现云端构建。

### GitHub Actions中的Rust环境配置

工作流会自动完成以下Rust环境配置：
- 安装稳定版Rust工具链
- 配置Android目标架构支持（armv7-linux-androideabi、aarch64-linux-android、i686-linux-android、x86_64-linux-android）
- 设置最小化的Rust配置文件以提高构建速度
- 自动缓存Rust依赖以加速后续构建

### 设置Secrets

在GitHub仓库中，前往`Settings > Secrets and variables > Actions`，添加以下Secrets：

| Secret名称 | 描述 | 默认值 |
|------------|------|--------|
| `ANDROID_KEYSTORE_BASE64` | keystore.jks文件的base64编码 | - |
| `KEYSTORE_PASSWORD` | Keystore密码 | - |
| `KEY_ALIAS` | 密钥别名 | - |
| `KEY_PASSWORD` | 密钥密码 | - |
| `APP_NAME` | 应用名称 | TenRun WebView |
| `BUNDLE_ID` | 应用包名 | com.tenrun.webview |
| `APP_VERSION` | 应用版本号 | 1.0.0 |
| `REMOTE_URL` | 要加载的远程URL | https://example.com |

> 注意：如果未设置Secret，工作流将使用tauri.conf.json中配置的默认值。

### 触发构建

推送代码到仓库或创建新的Release标签将自动触发构建：

```bash
# 推送代码到main分支触发构建
git push origin main

# 或创建Release标签触发带版本号的构建
git tag v1.0.0
git push origin v1.0.0
```

构建完成后，APK将作为Artifacts上传到GitHub Actions运行记录中，并在创建版本标签时自动创建GitHub Release。

## 自定义配置

### 修改加载的URL

编辑`src-tauri/tauri.conf.json`文件中的`url`字段，或通过环境变量`REMOTE_URL`设置。

### 自定义应用图标

替换`assets/icons/icon.png`文件，然后运行：

```bash
npm run tauri icon
```

### 调整WebView设置

编辑`android/app/src/main/java/com/tenrun/webview/MainActivity.kt`文件中的WebView配置。

## 重要提示

- **Keystore安全**：妥善保管您的keystore文件和密码。keystore丢失将导致无法更新已发布的应用。
- **Google Play政策**：纯WebView包装应用可能不符合Google Play商店政策，建议添加原生功能或隐私政策页面。
- **安全配置**：根据您的需求调整CSP和allowlist配置，以提高应用安全性。

## 故障排除

### `/home/runner/.cargo/bin/rustup` 进程退出码1错误

如果遇到GitHub Actions构建中出现`/home/runner/.cargo/bin/rustup`进程退出码1的错误，我们已在工作流中添加了以下优化和修复：

1. **增强的Rust环境调试**：添加了全面的环境检查步骤，包括：
   - 验证Rust工具链安装状态
   - 检查目标架构配置
   - 显示完整的环境变量和路径信息
   - 提供系统资源使用情况

2. **优化的Cargo缓存配置**：使用更精确的缓存键，包含Cargo.lock和Cargo.toml哈希值，避免缓存冲突和损坏。

3. **改进的错误处理**：添加了详细的日志输出和错误捕获，以便更容易诊断构建失败的根本原因。

4. **调整的目标平台格式**：确保Android目标平台格式正确，避免空格和格式问题导致的配置错误。

这些改进将帮助自动诊断和解决Rust环境配置问题，提高GitHub Actions构建的稳定性和成功率。

## 文档

- [架构说明](./docs/architecture.md)
- [安全与Play商店发布指南](./docs/security_and_playstore.md)
- [Android自定义功能](./docs/android_customization.md)
- [隐私政策模板](./docs/privacy_policy_template.md)

## 许可证

MIT