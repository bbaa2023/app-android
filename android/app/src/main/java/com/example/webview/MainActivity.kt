package com.example.webview

import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.widget.FrameLayout
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity

/**
 * Tauri WebView Android应用的主Activity
 * 提供WebView功能，支持全屏视频播放和自定义WebView配置
 */
class MainActivity : AppCompatActivity() {
    
    private lateinit var webView: WebView
    private var customView: View? = null
    private var customViewCallback: WebChromeClient.CustomViewCallback? = null
    private var originalOrientation: Int = 0
    private var fullscreenContainer: FrameLayout? = null
    
    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 保存原始屏幕方向
        originalOrientation = requestedOrientation
        
        // 创建全屏容器
        fullscreenContainer = FrameLayout(this)
        setContentView(fullscreenContainer)
        
        // 创建WebView
        webView = WebView(this)
        fullscreenContainer?.addView(webView, ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        ))
        
        // 配置WebView
        configureWebView(webView)
        
        // 设置WebChromeClient，处理全屏视频等
        webView.webChromeClient = object : WebChromeClient() {
            override fun onShowCustomView(view: View, callback: CustomViewCallback) {
                // 处理全屏视频显示
                if (customView != null) {
                    onHideCustomView()
                    return
                }
                
                customView = view
                customViewCallback = callback
                
                // 添加自定义视图到容器
                fullscreenContainer?.addView(customView, ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                ))
                
                // 隐藏WebView
                webView.visibility = View.GONE
                
                // 设置为横屏
                requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            }
            
            override fun onHideCustomView() {
                // 处理全屏视频隐藏
                if (customView == null) return
                
                // 恢复WebView可见性
                webView.visibility = View.VISIBLE
                
                // 移除自定义视图
                fullscreenContainer?.removeView(customView)
                customView = null
                
                // 调用回调
                customViewCallback?.onCustomViewHidden()
                customViewCallback = null
                
                // 恢复原始屏幕方向
                requestedOrientation = originalOrientation
            }
        }
        
        // 处理返回按钮
        handleBackButton()
    }
    
    /**
     * 配置WebView设置
     */
    @SuppressLint("SetJavaScriptEnabled")
    private fun configureWebView(webView: WebView) {
        val settings = webView.settings
        
        // 启用JavaScript
        settings.javaScriptEnabled = true
        
        // 启用DOM存储API
        settings.domStorageEnabled = true
        
        // 启用数据库存储API
        settings.databaseEnabled = true
        
        // 启用应用缓存API
        settings.setAppCacheEnabled(true)
        
        // 启用地理位置API
        settings.setGeolocationEnabled(true)
        
        // 启用文件访问
        settings.allowFileAccess = true
        
        // 启用混合内容（HTTP和HTTPS）
        settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        
        // 启用硬件加速
        webView.setLayerType(View.LAYER_TYPE_HARDWARE, null)
        
        // 设置缓存模式
        settings.cacheMode = WebSettings.LOAD_DEFAULT
        
        // 启用WebView调试（仅在Debug模式下）
        WebView.setWebContentsDebuggingEnabled(true)
    }
    
    /**
     * 处理返回按钮逻辑
     */
    private fun handleBackButton() {
        // 重写返回键行为
        onBackPressedDispatcher.addCallback(this) {
            when {
                // 如果在全屏模式，退出全屏
                customView != null -> {
                    webView.webChromeClient?.onHideCustomView()
                }
                // 如果WebView可以返回，则返回上一页
                webView.canGoBack() -> {
                    webView.goBack()
                }
                // 否则，显示退出确认对话框
                else -> {
                    showExitConfirmationDialog()
                }
            }
        }
    }
    
    /**
     * 显示退出确认对话框
     */
    private fun showExitConfirmationDialog() {
        AlertDialog.Builder(this)
            .setTitle("退出应用")
            .setMessage("确定要退出应用吗？")
            .setPositiveButton("确定") { _, _ -> finish() }
            .setNegativeButton("取消", null)
            .show()
    }
    
    /**
     * 附加WebView到Tauri应用
     * 此方法可以被Tauri框架调用以集成WebView
     */
    fun attachWebView(webView: WebView) {
        // 配置传入的WebView
        configureWebView(webView)
        
        // 替换当前WebView
        fullscreenContainer?.removeView(this.webView)
        this.webView = webView
        fullscreenContainer?.addView(this.webView, ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        ))
        
        // 重新设置WebChromeClient
        this.webView.webChromeClient = webView.webChromeClient
    }
}