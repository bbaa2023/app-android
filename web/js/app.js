// app.js - 主要应用逻辑

document.addEventListener('DOMContentLoaded', function() {
  // 获取DOM元素
  const backButton = document.getElementById('back-button');
  const forwardButton = document.getElementById('forward-button');
  const reloadButton = document.getElementById('reload-button');
  const urlInput = document.getElementById('url-input');
  const goButton = document.getElementById('go-button');
  const loadingIndicator = document.getElementById('loading-indicator');
  const webviewPlaceholder = document.getElementById('webview-placeholder');
  
  // 默认URL
  const defaultUrl = 'https://www.baidu.com';
  urlInput.value = defaultUrl;
  
  // 在Capacitor环境中，我们使用Browser插件来处理网页浏览
  // 这里我们模拟WebView行为，在实际的Capacitor应用中会被替换为原生WebView
  
  let isLoading = false;
  let currentUrl = '';
  let canGoBack = false;
  let canGoForward = false;
  
  // 模拟加载网页
  function loadUrl(url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url;
    }
    
    currentUrl = url;
    urlInput.value = url;
    
    // 显示加载状态
    isLoading = true;
    loadingIndicator.style.display = 'block';
    webviewPlaceholder.innerHTML = `正在加载 ${url}...`;
    
    // 模拟加载延迟
    setTimeout(() => {
      isLoading = false;
      loadingIndicator.style.display = 'none';
      webviewPlaceholder.innerHTML = `已加载页面: ${url}<br><br>在实际的Capacitor应用中，这里将显示网页内容。`;
      
      // 更新导航状态
      canGoBack = true;
      canGoForward = false;
      updateNavigationState();
    }, 1500);
  }
  
  // 更新导航按钮状态
  function updateNavigationState() {
    backButton.disabled = !canGoBack;
    forwardButton.disabled = !canGoForward;
  }
  
  // 事件监听器
  goButton.addEventListener('click', () => {
    loadUrl(urlInput.value);
  });
  
  urlInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      loadUrl(urlInput.value);
    }
  });
  
  backButton.addEventListener('click', () => {
    if (canGoBack) {
      canGoForward = true;
      canGoBack = false;
      loadUrl(defaultUrl);
    }
  });
  
  forwardButton.addEventListener('click', () => {
    if (canGoForward) {
      canGoForward = false;
      loadUrl(currentUrl);
    }
  });
  
  reloadButton.addEventListener('click', () => {
    loadUrl(currentUrl || defaultUrl);
  });
  
  // 初始加载
  loadUrl(defaultUrl);
  
  // 在实际的Capacitor应用中，我们会添加以下代码来使用原生WebView
  /*
  // 导入Capacitor插件
  import { Browser } from '@capacitor/browser';
  
  // 打开浏览器
  async function openBrowser(url) {
    await Browser.open({ url: url });
  }
  */
});