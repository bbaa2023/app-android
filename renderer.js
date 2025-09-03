// 获取DOM元素
const webview = document.getElementById('webview');
const urlInput = document.getElementById('url-input');
const goButton = document.getElementById('go-button');
const backButton = document.getElementById('back-button');
const forwardButton = document.getElementById('forward-button');
const reloadButton = document.getElementById('reload-button');

// 窗口控制按钮
const minimizeBtn = document.getElementById('minimize-btn');
const maximizeBtn = document.getElementById('maximize-btn');
const closeBtn = document.getElementById('close-btn');

// 设置初始URL
urlInput.value = 'https://www.example.com';

// 导航到指定URL
function navigateTo(url) {
  // 确保URL格式正确
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://' + url;
  }
  webview.src = url;
  urlInput.value = url;
}

// 按钮事件监听
goButton.addEventListener('click', () => {
  navigateTo(urlInput.value);
});

backButton.addEventListener('click', () => {
  if (webview.canGoBack()) {
    webview.goBack();
  }
});

forwardButton.addEventListener('click', () => {
  if (webview.canGoForward()) {
    webview.goForward();
  }
});

reloadButton.addEventListener('click', () => {
  webview.reload();
});

// 回车键导航
urlInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') {
    navigateTo(urlInput.value);
  }
});

// WebView事件监听
webview.addEventListener('did-start-loading', () => {
  document.body.classList.add('loading');
});

webview.addEventListener('did-stop-loading', () => {
  document.body.classList.remove('loading');
});

webview.addEventListener('did-navigate', (event) => {
  urlInput.value = event.url;
});

// 初始化时更新按钮状态
webview.addEventListener('dom-ready', () => {
  backButton.disabled = !webview.canGoBack();
  forwardButton.disabled = !webview.canGoForward();
});

// 每次导航后更新按钮状态
webview.addEventListener('did-navigate', () => {
  backButton.disabled = !webview.canGoBack();
  forwardButton.disabled = !webview.canGoForward();
});

// 窗口控制按钮事件
if (minimizeBtn) {
  minimizeBtn.addEventListener('click', () => {
    window.electronAPI.minimizeWindow();
  });
}

if (maximizeBtn) {
  maximizeBtn.addEventListener('click', () => {
    window.electronAPI.maximizeWindow();
  });
}

if (closeBtn) {
  closeBtn.addEventListener('click', () => {
    window.electronAPI.closeWindow();
  });
}

// 获取应用版本
window.electronAPI.getAppVersion().then(version => {
  console.log(`应用版本: ${version}`);
});

// 处理外部链接
webview.addEventListener('new-window', (e) => {
  const protocol = new URL(e.url).protocol;
  if (protocol === 'http:' || protocol === 'https:') {
    window.electronAPI.openExternalLink(e.url);
  }
});