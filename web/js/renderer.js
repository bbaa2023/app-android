// renderer.js - 处理与Capacitor原生功能的交互

document.addEventListener('DOMContentLoaded', function() {
  // 在这里我们将添加与Capacitor原生功能的交互代码
  // 例如处理返回按钮、状态栏颜色等
  
  // 检测是否在Capacitor环境中运行
  function isCapacitorEnvironment() {
    return window.Capacitor !== undefined;
  }
  
  // 当应用在Capacitor环境中运行时，我们需要处理一些特定的行为
  if (isCapacitorEnvironment()) {
    console.log('应用在Capacitor环境中运行');
    
    // 导入Capacitor插件
    const { App } = window.Capacitor.Plugins;
    const { StatusBar } = window.Capacitor.Plugins;
    
    // 设置状态栏颜色
    StatusBar.setBackgroundColor({ color: '#2c3e50' });
    
    // 处理Android返回按钮
    App.addListener('backButton', function() {
      // 获取当前WebView状态
      const backButton = document.getElementById('back-button');
      
      if (!backButton.disabled) {
        // 如果可以返回，则触发返回按钮点击
        backButton.click();
      } else {
        // 否则，询问用户是否要退出应用
        if (confirm('确定要退出应用吗？')) {
          App.exitApp();
        }
      }
    });
  } else {
    console.log('应用在Web环境中运行');
  }
});