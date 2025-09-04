# 尝试使用PowerShell检查YAML文件格式
$ErrorActionPreference = "Stop"

try {
    # 读取文件内容
    $fileContent = Get-Content -Path '.github/workflows/build.yml' -Raw
    
    # 尝试进行简单的YAML解析检查
    # 这里我们只是检查基本的YAML结构元素是否存在
    if ($fileContent -match 'name:') {
        Write-Host "✅ 文件包含name字段"
    }
    
    if ($fileContent -match 'on:') {
        Write-Host "✅ 文件包含on字段"
    }
    
    if ($fileContent -match 'jobs:') {
        Write-Host "✅ 文件包含jobs字段"
    }
    
    # 检查第57行附近的内容
    $lines = Get-Content -Path '.github/workflows/build.yml'
    Write-Host "
第55-60行内容:
"
    $lines[54..59] | ForEach-Object { Write-Host "$_" }
    
    # 检查缩进是否一致（使用空格或制表符）
    $indentation = $lines | Select-Object -Skip 5 -First 10 | Where-Object { $_ -match '^\s+' } | ForEach-Object { 
        $matches[0].Length 
    } | Select-Object -Unique
    
    if ($indentation.Count -gt 1) {
        Write-Host "
⚠️  警告: 发现不同的缩进长度: $($indentation -join ', ')"
    } else {
        Write-Host "
✅  缩进看起来一致"
    }
    
    Write-Host "
✅ 文件结构检查完成。如需更深入的YAML验证，请使用专门的YAML解析工具。"
} catch {
    Write-Host "❌ 文件检查过程中发生错误: $($_.Exception.Message)"
}