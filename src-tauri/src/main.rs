// Tauri v2 WebView Android APK 主程序
// 负责创建主窗口并加载远程URL

// 导入必要的库
use std::{env, fs};
use tauri::{Manager, WebviewWindowBuilder};
use std::path::Path;

// 从.env文件读取环境变量
fn load_env_from_file() {
    // 首先尝试从.env.local读取（优先级更高）
    let env_files = [".env.local", ".env"];
    
    for env_file in &env_files {
        if Path::new(env_file).exists() {
            if let Ok(content) = fs::read_to_string(env_file) {
                for line in content.lines() {
                    // 忽略注释和空行
                    if line.starts_with('#') || line.trim().is_empty() {
                        continue;
                    }
                    
                    // 解析键值对
                    if let Some((key, value)) = line.split_once('=') {
                        let key = key.trim();
                        let value = value.trim().trim_matches('"');
                        
                        // 只在环境变量未设置时设置
                        if env::var(key).is_err() {
                            env::set_var(key, value);
                        }
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
    let remote_url = env::var("DEFAULT_URL")
        .unwrap_or_else(|_| env::var("REMOTE_URL")
        .unwrap_or_else(|_| "https://www.example.com".to_string()));
    
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