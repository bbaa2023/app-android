// Electron Forge配置文件
module.exports = {
  packagerConfig: {
    asar: true, // 将应用打包为asar格式
    icon: './assets/icon', // 应用图标，不需要扩展名
    name: '腾润WebView应用',
    executableName: 'tenrun-webview-app',
    appBundleId: 'com.tenrun.webview',
    appCategoryType: 'public.app-category.productivity',
    extraResource: [
      './assets'
    ]
  },
  rebuildConfig: {},
  makers: [
    // Windows平台
    {
      name: '@electron-forge/maker-squirrel',
      config: {
        name: 'tenrun-webview-app',
        authors: 'TenRun Tech',
        description: '腾润WebView应用',
        setupIcon: './assets/icon.ico',
      },
    },
    // macOS平台
    {
      name: '@electron-forge/maker-dmg',
      config: {
        icon: './assets/icon.icns',
        background: './assets/dmg-background.png',
      },
    },
    // Linux平台
    {
      name: '@electron-forge/maker-deb',
      config: {
        options: {
          maintainer: 'TenRun Tech',
          homepage: 'https://example.com',
          icon: './assets/icon.png',
        },
      },
    },
    {
      name: '@electron-forge/maker-rpm',
      config: {
        options: {
          maintainer: 'TenRun Tech',
          homepage: 'https://example.com',
          icon: './assets/icon.png',
        },
      },
    },
  ],
  plugins: [
    {
      name: '@electron-forge/plugin-auto-unpack-natives',
      config: {},
    },
  ],
};