package com.tenrun.webview;

import com.getcapacitor.BridgeActivity;
import android.webkit.WebSettings;
import android.os.Bundle;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // 安全的WebView配置
        if (this.bridge != null && this.bridge.getWebView() != null) {
            WebSettings settings = this.bridge.getWebView().getSettings();
            
            // 安全设置
            settings.setAllowFileAccess(false);
            settings.setAllowContentAccess(false);
            settings.setAllowFileAccessFromFileURLs(false);
            settings.setAllowUniversalAccessFromFileURLs(false);
            settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
            
            // 性能优化
            settings.setRenderPriority(WebSettings.RenderPriority.HIGH);
            
            // 缓存优化
            settings.setDomStorageEnabled(true);
            settings.setAppCacheEnabled(true);
            settings.setAppCachePath(getApplicationContext().getCacheDir().getAbsolutePath());
            settings.setCacheMode(WebSettings.LOAD_DEFAULT);
            
            // 启用数据库存储
            settings.setDatabaseEnabled(true);
        }
    }
}
