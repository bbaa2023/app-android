import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  // 指定入口文件
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'src/index.html'),
      },
    },
  },
  // 开发服务器配置
  server: {
    port: 3000,
    strictPort: true,
    open: true,
  },
  // 环境变量替换
  define: {
    'process.env.APP_NAME': JSON.stringify(process.env.APP_NAME || 'Tauri WebView App'),
    'process.env.APP_VERSION': JSON.stringify(process.env.APP_VERSION || '1.0.0'),
    'process.env.BUNDLE_ID': JSON.stringify(process.env.BUNDLE_ID || 'com.tenrun.webview'),
  },
  // 资源处理
  publicDir: 'assets',
});