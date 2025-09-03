# 安全指南与 Google Play Store 上架注意事项

## 安全风险与缓解措施

### 远程网页加载风险

**风险**：
- 远程内容可能被篡改或注入恶意代码
- 中间人攻击可能拦截或修改内容
- 远程服务器可能被攻击或控制

**缓解措施**：
1. **强制使用 HTTPS**：确保所有远程内容通过 HTTPS 加载
2. **实施内容安全策略 (CSP)**：限制可执行代码和可加载资源的来源
3. **子资源完整性 (SRI)**：为关键脚本和样式添加完整性哈希
4. **证书固定**：在 Android WebView 中实施证书固定，防止中间人攻击
5. **定期更新检查**：实现机制检查远程内容是否有更新或被篡改

### WebView 安全配置

**最佳实践**：

1. **禁用危险功能**：
   ```kotlin
   webView.settings.apply {
       javaScriptEnabled = true  // 仅在必要时启用
       allowFileAccess = false
       allowContentAccess = false
       allowFileAccessFromFileURLs = false
       allowUniversalAccessFromFileURLs = false
   }
   ```

2. **安全处理 JavaScript 接口**：
   ```kotlin
   // 使用 @JavascriptInterface 注解并验证输入
   class WebAppInterface(private val context: Context) {
       @JavascriptInterface
       fun performAction(input: String): String {
           // 验证输入
           return if (isValidInput(input)) {
               // 执行操作
           } else {
               "Invalid input"
           }
       }
   }
   ```

3. **实施 CSP**：在 `tauri.conf.json` 中配置：
   ```json
   "security": {
     "csp": "default-src 'self' https://trusted-domain.com; script-src 'self' https://trusted-domain.com; style-src 'self' https://trusted-domain.com; img-src 'self' https://trusted-domain.com data:;"
   }
   ```

### Tauri API 权限控制

**风险**：过度授权 Tauri API 可能导致安全漏洞

**最佳实践**：

1. **最小权限原则**：在 `tauri.conf.json` 中仅启用必要的 API：
   ```json
   "allowlist": {
     "http": {
       "all": false,
       "request": true,
       "scope": ["https://api.example.com/*"]
     },
     "fs": {
       "all": false,
       "readFile": true,
       "scope": ["$RESOURCE/*"]
     }
   }
   ```

2. **自定义命令验证**：对自定义命令进行严格验证：
   ```rust
   #[tauri::command]
   fn secure_command(input: String) -> Result<String, String> {
       // 验证输入
       if !is_valid_input(&input) {
           return Err("Invalid input".into());
       }
       
       // 执行操作
       Ok("Success".into())
   }
   ```

## Google Play Store 上架注意事项

### 政策合规

1. **WebView 应用政策**：
   - Google Play 对纯 WebView 应用有严格限制
   - 应用必须提供超出网站的实质性功能
   - 不得仅是网站的简单包装

2. **必要的原生功能示例**：
   - 离线功能和本地存储
   - 设备传感器集成（相机、GPS等）
   - 原生通知和后台服务
   - 设备特定优化和适配

3. **避免被拒的建议**：
   - 添加至少 2-3 个实质性原生功能
   - 确保应用名称和品牌与网站一致（如果是自有网站）
   - 提供清晰的隐私政策
   - 避免使用通用或误导性描述

### 隐私政策要求

1. **必须提供隐私政策**：
   - 在 Play Console 中提供隐私政策 URL
   - 在应用内提供隐私政策访问入口

2. **隐私政策必须包含**：
   - 收集的数据类型和用途
   - 数据共享和安全措施
   - 用户权利和选择
   - 联系方式

3. **数据安全表格**：
   - 在 Play Console 中填写数据安全表格
   - 准确声明所有数据收集和使用情况

## Keystore 管理重要性

### 风险

- **Keystore 丢失**：无法更新已发布的应用
- **Keystore 泄露**：可能导致应用被冒名顶替
- **密码遗忘**：无法使用 Keystore 签名

### 最佳实践

1. **安全备份**：
   - 将 Keystore 文件备份到多个安全位置
   - 使用加密存储解决方案
   - 考虑使用密钥管理服务

2. **密码管理**：
   - 使用强密码
   - 使用密码管理器安全存储
   - 记录密码恢复流程

3. **CI/CD 安全**：
   - 使用加密的环境变量或 Secrets
   - 避免在日志中打印密钥信息
   - 定期轮换 CI/CD 访问令牌

## 安全检查清单

- [ ] 配置了严格的 CSP
- [ ] 限制了 Tauri API allowlist
- [ ] 实施了 HTTPS 强制和证书验证
- [ ] 安全配置了 WebView 设置
- [ ] 验证了所有 JavaScript 接口输入
- [ ] 添加了足够的原生功能以符合 Play Store 政策
- [ ] 创建并发布了隐私政策
- [ ] 安全备份了 Keystore 和密码
- [ ] 在 CI/CD 中安全存储了敏感信息
- [ ] 实施了应用更新机制

## 结论

安全是一个持续的过程，而不是一次性的工作。定期审查和更新安全措施，关注 Google Play 政策变更，并保持应用和依赖项的更新，这些都是维护应用安全和合规的关键步骤。