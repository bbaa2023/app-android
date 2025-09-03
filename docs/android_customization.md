# Android 自定义功能指南

本文档提供了如何为 Tauri WebView Android 应用添加常用原生功能的指导，包括开机启动、前台服务、推送通知等。这些功能可以增强应用体验，并提高 Google Play 商店接受度。

## 开机启动功能

### 步骤 1: 添加权限

在 `android/app/src/main/AndroidManifest.xml` 中添加以下权限：

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 步骤 2: 创建 BootReceiver

创建 `android/app/src/main/java/com/example/webview/BootReceiver.kt` 文件：

```kotlin
package com.example.webview

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                // 可选：传递参数表明是从开机启动打开的
                putExtra("FROM_BOOT", true)
            }
            
            // 直接启动应用
            context.startActivity(launchIntent)
            
            // 或者启动前台服务
            // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //     context.startForegroundService(Intent(context, ForegroundService::class.java))
            // } else {
            //     context.startService(Intent(context, ForegroundService::class.java))
            // }
        }
    }
}
```

### 步骤 3: 在 AndroidManifest.xml 中注册接收器

```xml
<application ...>
    <!-- 其他组件 -->
    
    <receiver
        android:name=".BootReceiver"
        android:enabled="true"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED" />
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>
    </receiver>
</application>
```

## 前台服务

前台服务可以让应用在后台持续运行，并在通知栏显示一个通知。

### 步骤 1: 添加权限

在 `AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### 步骤 2: 创建通知渠道（Android 8.0+）

在 `MainActivity.kt` 的 `onCreate` 方法中添加：

```kotlin
private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channelId = "foreground_service_channel"
        val channelName = "Foreground Service"
        val channel = NotificationChannel(
            channelId,
            channelName,
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "用于保持应用在后台运行"
            setShowBadge(false)
        }
        
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)
    }
}
```

### 步骤 3: 创建前台服务

创建 `android/app/src/main/java/com/example/webview/ForegroundService.kt` 文件：

```kotlin
package com.example.webview

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class ForegroundService : Service() {
    companion object {
        const val CHANNEL_ID = "foreground_service_channel"
        const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("应用正在运行")
            .setContentText("点击返回应用")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(NOTIFICATION_ID, notification)

        // 在这里执行后台任务
        // ...

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "前台服务",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "保持应用在后台运行"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
```

### 步骤 4: 在 AndroidManifest.xml 中注册服务

```xml
<application ...>
    <!-- 其他组件 -->
    
    <service
        android:name=".ForegroundService"
        android:enabled="true"
        android:exported="false" />
</application>
```

### 步骤 5: 启动和停止服务

在 `MainActivity.kt` 中添加：

```kotlin
// 启动服务
private fun startForegroundService() {
    val serviceIntent = Intent(this, ForegroundService::class.java)
    
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        startForegroundService(serviceIntent)
    } else {
        startService(serviceIntent)
    }
}

// 停止服务
private fun stopForegroundService() {
    val serviceIntent = Intent(this, ForegroundService::class.java)
    stopService(serviceIntent)
}
```

## 推送通知

### 步骤 1: 添加 Firebase Cloud Messaging 依赖

在 `android/app/build.gradle` 中添加：

```gradle
dependencies {
    // 其他依赖
    implementation platform('com.google.firebase:firebase-bom:32.0.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

在 `android/build.gradle` 中添加：

```gradle
buildscript {
    dependencies {
        // 其他依赖
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

在 `android/app/build.gradle` 底部添加：

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 步骤 2: 创建 FCM 服务

创建 `android/app/src/main/java/com/example/webview/FCMService.kt` 文件：

```kotlin
package com.example.webview

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FCMService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // 处理通知消息
        remoteMessage.notification?.let {
            sendNotification(it.title ?: "通知", it.body ?: "")
        }

        // 处理数据消息
        remoteMessage.data.isNotEmpty().let {
            // 如果WebView已加载，可以将数据传递给WebView
            val dataJson = remoteMessage.data.toString()
            // 例如，可以通过共享偏好设置存储数据，让MainActivity读取
            val sharedPref = getSharedPreferences("FCM_DATA", Context.MODE_PRIVATE)
            with(sharedPref.edit()) {
                putString("latest_data", dataJson)
                putLong("timestamp", System.currentTimeMillis())
                apply()
            }
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // 将新令牌发送到服务器
        sendRegistrationToServer(token)
    }

    private fun sendRegistrationToServer(token: String) {
        // 实现将令牌发送到应用服务器的逻辑
        // 例如，可以通过共享偏好设置存储令牌，让MainActivity读取并发送
        val sharedPref = getSharedPreferences("FCM_TOKEN", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("token", token)
            apply()
        }
    }

    private fun sendNotification(title: String, messageBody: String) {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val channelId = "fcm_default_channel"
        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(messageBody)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setContentIntent(pendingIntent)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Android O 需要通知渠道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "推送通知",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(channel)
        }

        notificationManager.notify(0, notificationBuilder.build())
    }
}
```

### 步骤 3: 在 AndroidManifest.xml 中注册服务

```xml
<application ...>
    <!-- 其他组件 -->
    
    <service
        android:name=".FCMService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
    
    <!-- 设置默认通知图标和颜色 -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/ic_notification" />
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@color/colorAccent" />
</application>
```

### 步骤 4: 在 MainActivity 中获取和处理 FCM 令牌

在 `MainActivity.kt` 中添加：

```kotlin
private fun setupFCM() {
    FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
        if (!task.isSuccessful) {
            Log.w(TAG, "获取FCM令牌失败", task.exception)
            return@addOnCompleteListener
        }

        // 获取新令牌
        val token = task.result
        
        // 将令牌传递给WebView
        webView?.evaluateJavascript(
            "if (window.onFCMTokenReceived) { window.onFCMTokenReceived('$token'); }",
            null
        )
        
        // 检查是否有待处理的FCM数据
        checkPendingFCMData()
    }
}

private fun checkPendingFCMData() {
    val sharedPref = getSharedPreferences("FCM_DATA", Context.MODE_PRIVATE)
    val latestData = sharedPref.getString("latest_data", null)
    val timestamp = sharedPref.getLong("timestamp", 0)
    
    // 如果有最近的数据（例如在过去5分钟内收到）
    if (latestData != null && System.currentTimeMillis() - timestamp < 5 * 60 * 1000) {
        // 将数据传递给WebView
        webView?.evaluateJavascript(
            "if (window.onFCMDataReceived) { window.onFCMDataReceived($latestData); }",
            null
        )
        
        // 清除已处理的数据
        with(sharedPref.edit()) {
            remove("latest_data")
            remove("timestamp")
            apply()
        }
    }
}
```

## 本地通知

### 步骤 1: 创建通知辅助类

创建 `android/app/src/main/java/com/example/webview/NotificationHelper.kt` 文件：

```kotlin
package com.example.webview

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class NotificationHelper(private val context: Context) {

    companion object {
        const val CHANNEL_ID = "local_notifications"
        private var notificationId = 0
    }

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "本地通知"
            val descriptionText = "应用本地通知"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showNotification(title: String, message: String, deepLink: String? = null) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            deepLink?.let { putExtra("DEEP_LINK", it) }
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent, PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId++, builder.build())
    }
}
```

### 步骤 2: 在 MainActivity 中添加 JavaScript 接口

在 `MainActivity.kt` 中添加：

```kotlin
class WebAppInterface(private val context: Context) {
    private val notificationHelper = NotificationHelper(context)
    
    @JavascriptInterface
    fun showNotification(title: String, message: String, deepLink: String? = null) {
        notificationHelper.showNotification(title, message, deepLink)
    }
}

// 在 onCreate 或 attachWebView 方法中添加：
webView.addJavascriptInterface(WebAppInterface(this), "AndroidApp")
```

### 步骤 3: 在 WebView 中使用接口

在前端 JavaScript 中：

```javascript
// 检查接口是否可用
if (window.AndroidApp) {
    // 显示本地通知
    window.AndroidApp.showNotification(
        "通知标题", 
        "通知内容", 
        "app://open/section/123"
    );
}
```

## 深层链接 (Deep Links)

### 步骤 1: 在 AndroidManifest.xml 中配置 Intent 过滤器

```xml
<activity
    android:name=".MainActivity"
    ... >
    
    <!-- 现有的 intent-filter -->
    
    <!-- 添加自定义 URL Scheme -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" />
    </intent-filter>
    
    <!-- 添加 App Links (Android 6.0+) -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" 
              android:host="example.com"
              android:pathPrefix="/app" />
    </intent-filter>
</activity>
```

### 步骤 2: 在 MainActivity 中处理深层链接

在 `MainActivity.kt` 中添加：

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // 现有代码...
    
    // 处理启动 Intent
    handleIntent(intent)
}

override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    handleIntent(intent)
}

private fun handleIntent(intent: Intent) {
    // 处理深层链接
    when (intent.action) {
        Intent.ACTION_VIEW -> {
            val uri = intent.data
            if (uri != null) {
                // 处理 URI
                val deepLink = uri.toString()
                
                // 如果 WebView 已加载，直接传递给 WebView
                webView?.let { webView ->
                    webView.evaluateJavascript(
                        "if (window.handleDeepLink) { window.handleDeepLink('$deepLink'); }",
                        null
                    )
                } ?: run {
                    // 否则，保存以便 WebView 加载后使用
                    pendingDeepLink = deepLink
                }
            }
        }
    }
    
    // 处理从通知启动的情况
    intent.getStringExtra("DEEP_LINK")?.let { deepLink ->
        webView?.evaluateJavascript(
            "if (window.handleDeepLink) { window.handleDeepLink('$deepLink'); }",
            null
        )
    }
}

// 在 WebView 加载完成后处理待处理的深层链接
private var pendingDeepLink: String? = null

// 在 WebView 加载完成的回调中
webView.webViewClient = object : WebViewClient() {
    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        
        // 处理待处理的深层链接
        pendingDeepLink?.let { deepLink ->
            webView?.evaluateJavascript(
                "if (window.handleDeepLink) { window.handleDeepLink('$deepLink'); }",
                null
            )
            pendingDeepLink = null
        }
    }
}
```

## 总结

以上是一些常用的 Android 原生功能实现方法，可以根据应用需求选择性地添加。这些功能不仅可以增强应用体验，还可以提高 Google Play 商店接受度，因为它们展示了应用不仅仅是一个简单的 WebView 包装器。

实现这些功能时，请确保：

1. 遵循 Android 最佳实践和设计模式
2. 考虑不同 Android 版本的兼容性
3. 尊重用户隐私和系统资源
4. 在 `tauri.conf.json` 中适当配置 allowlist 以允许 JavaScript 与原生功能交互

这些功能可以根据需要组合使用，创建一个功能丰富的混合应用。