# 安卓应用本地打包脚本

# 确保脚本在错误时停止
$ErrorActionPreference = "Stop"

# 显示欢迎信息
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "  腾润WebView应用 - 安卓打包工具  " -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# 检查环境
Write-Host "[1/7] 检查环境..." -ForegroundColor Yellow

# 检查Node.js
try {
    $nodeVersion = node -v
    Write-Host "✓ Node.js已安装: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ 未检测到Node.js，请安装Node.js后重试" -ForegroundColor Red
    exit 1
}

# 检查JDK
try {
    $javaVersion = java -version 2>&1
    Write-Host "✓ Java已安装" -ForegroundColor Green
} catch {
    Write-Host "✗ 未检测到Java，请安装JDK后重试" -ForegroundColor Red
    exit 1
}

# 检查Android SDK
$androidSdkPath = $env:ANDROID_HOME
if (-not $androidSdkPath) {
    $androidSdkPath = $env:ANDROID_SDK_ROOT
}

if ($androidSdkPath -and (Test-Path $androidSdkPath)) {
    Write-Host "✓ Android SDK已安装: $androidSdkPath" -ForegroundColor Green
} else {
    Write-Host "✗ 未检测到Android SDK，请安装Android SDK并设置ANDROID_HOME环境变量" -ForegroundColor Red
    exit 1
}

# 安装依赖
Write-Host ""
Write-Host "[2/7] 安装依赖..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 依赖安装失败" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 依赖安装成功" -ForegroundColor Green

# 构建Web应用
Write-Host ""
Write-Host "[3/7] 构建Web应用..." -ForegroundColor Yellow

# 确保web目录存在
if (-not (Test-Path "web")) {
    Write-Host "✗ web目录不存在" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Web应用已准备就绪" -ForegroundColor Green

# 同步Capacitor项目
Write-Host ""
Write-Host "[4/7] 同步Capacitor项目..." -ForegroundColor Yellow
npx cap sync android

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Capacitor同步失败" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Capacitor同步成功" -ForegroundColor Green

# 创建签名密钥
Write-Host ""
Write-Host "[5/7] 检查签名密钥..." -ForegroundColor Yellow

$keystorePath = "android/app/keystore.jks"

if (-not (Test-Path $keystorePath)) {
    Write-Host "未找到签名密钥，是否创建新的签名密钥？(Y/N)" -ForegroundColor Yellow
    $createKeystore = Read-Host
    
    if ($createKeystore -eq "Y" -or $createKeystore -eq "y") {
        $keyAlias = Read-Host "请输入密钥别名 (默认: key0)"
        if (-not $keyAlias) { $keyAlias = "key0" }
        
        $keystorePassword = Read-Host "请输入密钥库密码 (默认: password)" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePassword)
        $keystorePasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        if (-not $keystorePasswordText) { $keystorePasswordText = "password" }
        
        $keyPassword = Read-Host "请输入密钥密码 (默认: 与密钥库密码相同)" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword)
        $keyPasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        if (-not $keyPasswordText) { $keyPasswordText = $keystorePasswordText }
        
        # 创建密钥库目录
        New-Item -ItemType Directory -Force -Path "android/app" | Out-Null
        
        # 使用keytool创建密钥库
        $keytoolCmd = "keytool -genkey -v -keystore `"$keystorePath`" -alias $keyAlias -keyalg RSA -keysize 2048 -validity 10000 -storepass $keystorePasswordText -keypass $keyPasswordText"
        Invoke-Expression $keytoolCmd
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ 密钥创建失败" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "✓ 密钥创建成功: $keystorePath" -ForegroundColor Green
        
        # 保存密钥信息到环境变量文件
        $envContent = @"
        KEYSTORE_FILE=$keystorePath
        KEYSTORE_PASSWORD=$keystorePasswordText
        KEY_ALIAS=$keyAlias
        KEY_PASSWORD=$keyPasswordText
"@
        
        Set-Content -Path ".env.local" -Value $envContent
        Write-Host "✓ 密钥信息已保存到.env.local文件" -ForegroundColor Green
    } else {
        Write-Host "✗ 未创建签名密钥，无法继续构建" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ 已找到签名密钥: $keystorePath" -ForegroundColor Green
    
    # 检查环境变量文件
    if (-not (Test-Path ".env.local")) {
        Write-Host "未找到.env.local文件，请创建该文件并设置以下变量:" -ForegroundColor Yellow
        Write-Host "KEYSTORE_FILE=$keystorePath" -ForegroundColor Yellow
        Write-Host "KEYSTORE_PASSWORD=您的密钥库密码" -ForegroundColor Yellow
        Write-Host "KEY_ALIAS=您的密钥别名" -ForegroundColor Yellow
        Write-Host "KEY_PASSWORD=您的密钥密码" -ForegroundColor Yellow
        
        $createEnvFile = Read-Host "是否现在创建.env.local文件？(Y/N)"
        
        if ($createEnvFile -eq "Y" -or $createEnvFile -eq "y") {
            $keystorePassword = Read-Host "请输入密钥库密码" -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePassword)
            $keystorePasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            $keyAlias = Read-Host "请输入密钥别名"
            
            $keyPassword = Read-Host "请输入密钥密码" -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword)
            $keyPasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            $envContent = @"
            KEYSTORE_FILE=$keystorePath
            KEYSTORE_PASSWORD=$keystorePasswordText
            KEY_ALIAS=$keyAlias
            KEY_PASSWORD=$keyPasswordText
"@
            
            Set-Content -Path ".env.local" -Value $envContent
            Write-Host "✓ .env.local文件已创建" -ForegroundColor Green
        } else {
            Write-Host "✗ 未创建.env.local文件，无法继续构建" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✓ 已找到.env.local文件" -ForegroundColor Green
    }
}

# 构建Android应用
Write-Host ""
Write-Host "[6/7] 构建Android应用..." -ForegroundColor Yellow

# 读取环境变量
$envVars = Get-Content ".env.local" | ForEach-Object {
    if ($_ -match "^([^=]+)=(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        [PSCustomObject]@{
            Key = $key
            Value = $value
        }
    }
}

# 设置环境变量
$envVars | ForEach-Object {
    Set-Item -Path "env:$($_.Key)" -Value $_.Value
}

# 执行Gradle构建
Push-Location android
try {
    ./gradlew assembleRelease
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Android应用构建失败" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ Android应用构建成功" -ForegroundColor Green
} finally {
    Pop-Location
}

# 复制APK到输出目录
Write-Host ""
Write-Host "[7/7] 复制APK到输出目录..." -ForegroundColor Yellow

$apkPath = "android/app/build/outputs/apk/release"
$outputDir = "dist"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

Copy-Item "$apkPath/*.apk" -Destination $outputDir

Write-Host "✓ APK已复制到$outputDir目录" -ForegroundColor Green

# 完成
Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "  构建完成！  " -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "APK文件位置: $outputDir" -ForegroundColor Green
Write-Host ""