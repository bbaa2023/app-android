// preload.js
const { contextBridge, ipcRenderer } = require('electron');

// 在window对象上暴露API，以便渲染进程使用
contextBridge.exposeInMainWorld('electronAPI', {
  // 获取应用版本
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  
  // 打开外部链接
  openExternalLink: (url) => ipcRenderer.invoke('open-external-link', url),
  
  // 最小化窗口
  minimizeWindow: () => ipcRenderer.send('minimize-window'),
  
  // 最大化窗口
  maximizeWindow: () => ipcRenderer.send('maximize-window'),
  
  // 关闭窗口
  closeWindow: () => ipcRenderer.send('close-window'),
  
  // 设置标题
  setTitle: (title) => ipcRenderer.send('set-title', title),
  
  // 监听标题变化
  onTitleChange: (callback) => ipcRenderer.on('title-changed', callback),
});