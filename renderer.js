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

// 历史记录管理
let navigationHistory = [];
let currentHistoryIndex = -1;

// 设置初始URL
const defaultUrl = 'https://www.example.com';
urlInput.value = defaultUrl;

// 创建错误消息元素
function createErrorMessage(text) {
  // 移除已存在的错误消息
  const existingError = document.querySelector('.error-message');
  if (existingError) {
    existingError.remove();
  }
  
  const errorMessage = document.createElement('div');
  errorMessage.className = 'error-message';
  errorMessage.textContent = text;
  document.body.appendChild(errorMessage);
  
  // 3秒后自动移除错误消息
  setTimeout(() => {
    if (errorMessage.parentNode) {
      errorMessage.parentNode.removeChild(errorMessage);
    }
  }, 3000);
}

// 导航到指定URL
function navigateTo(url) {
  try {
    // 确保URL格式正确
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url;
    }
    
    // 验证URL格式
    new URL(url);
    
    // 更新历史记录
    if (currentHistoryIndex < navigationHistory.length - 1) {
      navigationHistory = navigationHistory.slice(0, currentHistoryIndex + 1);
    }
    navigationHistory.push(url);
    currentHistoryIndex = navigationHistory.length - 1;
    
    webview.src = url;
    urlInput.value = url;
    updateNavigationButtons();
  } catch (error) {
    createErrorMessage('无效的URL格式，请检查输入');
  }
}

// 检查是否可以后退
function canGoBack() {
  return currentHistoryIndex > 0;
}

// 检查是否可以前进
function canGoForward() {
  return currentHistoryIndex < navigationHistory.length - 1;
}

// 更新导航按钮状态
function updateNavigationButtons() {
  backButton.disabled = !canGoBack();
  forwardButton.disabled = !canGoForward();
}

// 后退导航
function goBack() {
  if (canGoBack()) {
    currentHistoryIndex--;
    webview.src = navigationHistory[currentHistoryIndex];
    urlInput.value = navigationHistory[currentHistoryIndex];
    updateNavigationButtons();
  }
}

// 前进导航
function goForward() {
  if (canGoForward()) {
    currentHistoryIndex++;
    webview.src = navigationHistory[currentHistoryIndex];
    urlInput.value = navigationHistory[currentHistoryIndex];
    updateNavigationButtons();
  }
}

// 按钮事件监听
goButton.addEventListener('click', () => {
  navigateTo(urlInput.value);
});

backButton.addEventListener('click', goBack);

forwardButton.addEventListener('click', goForward);

reloadButton.addEventListener('click', () => {
  if (webview.src) {
    webview.reload();
  } else {
    navigateTo(defaultUrl);
  }
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
  // 更新URL输入框，但不更新历史记录（避免重复）
  if (currentHistoryIndex >= 0 && navigationHistory[currentHistoryIndex] !== event.url) {
    urlInput.value = event.url;
  }
});

// 错误处理
webview.addEventListener('did-fail-load', (event, errorCode, errorDescription, validatedURL, isMainFrame) => {
  console.error(`Failed to load ${validatedURL}: ${errorDescription} (code: ${errorCode})`);
  createErrorMessage(`无法加载页面: ${errorDescription}`);
});

// 证书错误处理
webview.addEventListener('certificate-error', (event, url, error, certificate) => {
  event.preventDefault(); // 不要默认处理，避免忽略证书错误
  console.error(`Certificate error for ${url}: ${error}`);
  createErrorMessage('网站证书验证失败，无法安全访问');
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

// 初始化导航状态
function initializeNavigation() {
  navigateTo(defaultUrl);
}

// 获取应用版本
window.electronAPI.getAppVersion().then(version => {
  console.log(`App version: ${version}`);
});

// 初始化应用
initializeNavigation();

// 处理外部链接
webview.addEventListener('new-window', (e) => {
  const protocol = new URL(e.url).protocol;
  if (protocol === 'http:' || protocol === 'https:') {
    window.electronAPI.openExternalLink(e.url);
  }
});