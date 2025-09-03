// WebView应用配置文件
module.exports = {
  // 默认加载的网页URL
  defaultUrl: 'https://www.example.com',
  
  // 窗口配置
  window: {
    width: 1024,
    height: 768,
    minWidth: 800,
    minHeight: 600,
    title: '腾润WebView应用',
    icon: './assets/icon.svg',  // 应用图标路径
  },
  
  // WebView配置
  webPreferences: {
    nodeIntegration: false,      // 不在渲染进程中集成Node.js
    contextIsolation: true,      // 启用上下文隔离
    sandbox: true,               // 启用沙箱
    webSecurity: true,           // 启用web安全
    allowRunningInsecureContent: false,  // 不允许运行不安全的内容
  },
  
  // 应用功能配置
  features: {
    enableDevTools: false,       // 是否启用开发者工具
    enableNavigation: true,      // 是否启用导航控制
    enableUrlInput: true,        // 是否启用URL输入框
  }
};