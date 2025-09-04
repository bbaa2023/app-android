// renderer.js - Tauri WebView应用前端渲染脚本

document.addEventListener('DOMContentLoaded', function() {
  // 导入Tauri API（如果需要）
  // 注意：实际使用时需要先安装@tauri-apps/api依赖
  // import { appWindow, BackButton } from '@tauri-apps/api';
  
  console.log('Tauri WebView应用已加载');
  
  // 这里可以添加与Tauri原生功能的交互代码
  // 例如处理返回按钮、状态栏颜色等
  
  // 示例：处理返回按钮（需要在HTML中有对应的按钮元素）
  const backButton = document.getElementById('back-button');
  if (backButton) {
    backButton.addEventListener('click', function() {
      // 检查是否可以返回上一页
      if (window.history && window.history.length > 1) {
        window.history.back();
      } else {
        // 在Tauri环境中，可以使用以下代码来处理应用退出
        // 注意：需要在tauri.conf.json中配置allowlist
        // import { app } from '@tauri-apps/api';
        // if (confirm('确定要退出应用吗？')) {
        //   app.exit();
        // }
      }
    });
  }
});