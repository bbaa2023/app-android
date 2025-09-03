# Tauri WebView Android 应用架构

## 架构概览

```
+-------------------+
|     前端层        |
| (HTML/CSS/JS)     |
+--------+----------+
         |
         v
+--------+----------+
|    Tauri 层       |
| (Rust/WebView)    |
+--------+----------+
         |
         v
+--------+----------+
|   Android 层      |
| (Java/Kotlin)     |
+--------+----------+
         |
         v
+--------+----------+
|    CI/CD 层       |
| (GitHub Actions)  |
+-------------------+
```

## 各层逻辑关系

### 1. 前端层 (HTML/CSS/JavaScript)

前端层是用户直接交互的界面，负责：

- 提供用户界面和交互体验
- 通过 Tauri API 与原生功能通信
- 可以是本地打包的静态页面或远程加载的 Web 应用

**关键文件**：
- `src/index.html` - 本地打包的示例页面
- 其他前端资源（CSS、JavaScript、图片等）

### 2. Tauri 层 (Rust/WebView)

Tauri 层是连接前端和原生平台的桥梁，负责：

- 创建和管理 WebView 实例
- 提供 JavaScript API 供前端调用原生功能
- 处理权限和安全策略
- 管理应用生命周期

**关键文件**：
- `src-tauri/src/main.rs` - Rust 主程序
- `src-tauri/tauri.conf.json` - Tauri 配置文件

### 3. Android 层 (Java/Kotlin)

Android 层提供原生平台功能，负责：

- 实现 WebView 的原生配置和扩展
- 处理 Android 特有的生命周期和权限
- 提供原生 UI 组件（如全屏视频）
- 管理应用资源和配置

**关键文件**：
- `android/app/src/main/java/.../MainActivity.kt` - 主 Activity
- `android/app/src/main/AndroidManifest.xml` - Android 配置
- `android/app/src/main/res/` - Android 资源

### 4. CI/CD 层 (GitHub Actions)

CI/CD 层自动化构建和发布流程，负责：

- 自动构建 Android APK
- 管理签名和密钥
- 发布版本和更新
- 运行测试和质量检查

**关键文件**：
- `.github/workflows/android-build.yml` - GitHub Actions 工作流
- `scripts/prepare-keystore.sh` - 密钥准备脚本
- `scripts/build-local.sh` - 本地构建脚本

## 数据流

1. **用户交互流**：
   - 用户在前端界面交互
   - 前端通过 Tauri API 请求原生功能
   - Tauri 层处理请求并调用 Android 原生 API
   - Android 层执行操作并返回结果
   - 结果通过 Tauri 层传回前端显示

2. **构建流**：
   - 开发者提交代码到 GitHub
   - GitHub Actions 触发构建工作流
   - 工作流准备环境、解码密钥、构建前端
   - Tauri CLI 编译 Rust 代码并生成 Android 项目
   - Gradle 构建并签名 APK
   - 构建产物上传为 Artifact 或 Release

## 安全边界

- **CSP 策略**：限制前端可加载的资源和执行的脚本
- **Tauri allowlist**：限制前端可访问的原生 API
- **Android 权限**：限制应用可访问的系统资源
- **签名验证**：确保应用完整性和来源可信

## 扩展点

1. **前端扩展**：
   - 可替换为任何 Web 框架（React、Vue、Angular 等）
   - 可选择本地打包或远程加载

2. **Tauri 扩展**：
   - 可添加自定义 Rust 插件扩展功能
   - 可调整 allowlist 和 CSP 策略

3. **Android 扩展**：
   - 可添加原生 Android 功能和服务
   - 可自定义 WebView 行为和性能优化

4. **CI/CD 扩展**：
   - 可添加自动测试和代码质量检查
   - 可配置自动发布到应用商店