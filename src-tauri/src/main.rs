// Tauri v2 WebView Android APK 主程序
// 负责创建主窗口并加载远程URL

// 导入必要的库
use std::{env, fs};
use tauri::{Manager, WebviewWindowBuilder};
use std::path::Path;

// 从.env.local文件读取环境变量
fn load_env_from_file() {
    let env_file = ".env.local";
    if Path::new(env_file).exists() {
        if let Ok(content) = fs::read_to_string(env_file) {
            for line in content.lines() {
                if line.starts_with('#') || line.trim().is_empty() {
                    continue;
                }
                if let Some((key, value)) = line.split_once('=') {
                    let key = key.trim();
                    let value = value.trim().trim_matches('"');
                    if env::var(key).is_err() {
                        env::set_var(key, value);
                    }
                }
            }
        }
    }
}

// 主函数
fn main() {
    // 加载.env.local文件中的环境变量
    load_env_from_file();
    
    // 从环境变量获取远程URL，如果没有设置则使用默认值
    let remote_url = env::var("REMOTE_URL")
        .unwrap_or_else(|_| "https://example.com".to_string());
    
    // 打印加载的URL（仅在开发模式下）
    #[cfg(debug_assertions)]
    println!("Loading URL: {}", remote_url);
    
    // 初始化Tauri应用
    tauri::Builder::default()
        // 设置应用启动时的处理函数
        .setup(|app| {
            // 使用WebviewWindowBuilder创建窗口并加载远程URL
            WebviewWindowBuilder::new(app, "main", tauri::WebviewUrl::External(remote_url.parse().unwrap()))
                .title("TenRun WebView")
                .width(800)
                .height(600)
                .fullscreen(false)
                .resizable(true)
                .build()
                .expect("无法创建窗口");
            
            Ok(())
        })
        // 运行应用
        .run(tauri::generate_context!())
        .expect("Tauri应用运行失败");
}
}