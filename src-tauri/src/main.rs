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
        .unwrap_or_else(|_| "https://jp.wsxbz.xyz".to_string()));
    
    // 从环境变量获取窗口配置
    let window_width = env::var("WINDOW_WIDTH")
        .unwrap_or_else(|_| "800".to_string())
        .parse()
        .unwrap_or(800);
    
    let window_height = env::var("WINDOW_HEIGHT")
        .unwrap_or_else(|_| "600".to_string())
        .parse()
        .unwrap_or(600);
    
    let window_min_width = env::var("WINDOW_MIN_WIDTH")
        .unwrap_or_else(|_| "800".to_string())
        .parse()
        .unwrap_or(800);
    
    let window_min_height = env::var("WINDOW_MIN_HEIGHT")
        .unwrap_or_else(|_| "600".to_string())
        .parse()
        .unwrap_or(600);
    
    // 从环境变量获取功能配置
    let enable_dev_tools = env::var("ENABLE_DEV_TOOLS")
        .unwrap_or_else(|_| "false".to_string())
        .parse()
        .unwrap_or(false);
    
    // 打印加载的URL和配置（仅在开发模式下）
    #[cfg(debug_assertions)]
    {
        println!("Loading URL: {}", remote_url);
        println!("Window config: {}x{} (min: {}x{})", window_width, window_height, window_min_width, window_min_height);
        println!("DevTools enabled: {}", enable_dev_tools);
    }
    
    // 初始化Tauri应用
    tauri::Builder::default()
        // 设置应用启动时的处理函数
        .setup(|app| {
            // 使用WebviewWindowBuilder创建窗口并加载远程URL
            let mut window_builder = WebviewWindowBuilder::new(app, "main", tauri::WebviewUrl::External(remote_url.parse().unwrap()))
                .title("TenRun WebView")
                .width(window_width)
                .height(window_height)
                .min_width(window_min_width)
                .min_height(window_min_height)
                .fullscreen(false)
                .resizable(true);
            
            // 如果启用了开发者工具
            if enable_dev_tools {
                window_builder = window_builder.devtools();
            }
            
            window_builder
                .build()
                .expect("无法创建窗口");
            
            Ok(())
        })
        // 运行应用
        .run(tauri::generate_context!())
        .expect("Tauri应用运行失败");
}