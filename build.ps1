# Docker 构建脚本 (PowerShell)
# 使用方式: .\build.ps1 <directory_path> [tag]
# 示例: .\build.ps1 dotnet/sdk3.1
# 示例: .\build.ps1 nodejs/v16 1.1

param(
    [Parameter(Mandatory=$true)]
    [string]$DirectoryPath,
    
    [Parameter(Mandatory=$false)]
    [string]$Tag = "1.0"
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 检查配置文件
$ConfigFile = "build.config"
if (-not (Test-Path $ConfigFile)) {
    Write-Error "错误: 配置文件 $ConfigFile 不存在"
    exit 1
}

# 读取配置文件
$ConfigContent = Get-Content $ConfigFile
$DockerHost = ($ConfigContent | Where-Object { $_ -match "^docker-host=" }) -replace "docker-host=", ""
$Platform = ($ConfigContent | Where-Object { $_ -match "^platform=" }) -replace "platform=", ""

if ([string]::IsNullOrEmpty($DockerHost) -or [string]::IsNullOrEmpty($Platform)) {
    Write-Error "错误: 配置文件中缺少必要参数"
    exit 1
}

# 检查目录是否存在
if (-not (Test-Path $DirectoryPath -PathType Container)) {
    Write-Error "错误: 目录 $DirectoryPath 不存在"
    exit 1
}

# 检查 Dockerfile 是否存在
$DockerfilePath = ""
$DockerfileCandidate1 = Join-Path $DirectoryPath "Dockerfile"
$DockerfileCandidate2 = Join-Path $DirectoryPath "dockerfile"

if (Test-Path $DockerfileCandidate1) {
    $DockerfilePath = $DockerfileCandidate1
} elseif (Test-Path $DockerfileCandidate2) {
    $DockerfilePath = $DockerfileCandidate2
} else {
    Write-Error "错误: 在 $DirectoryPath 中找不到 Dockerfile 或 dockerfile"
    exit 1
}

# 生成镜像名称和标签
# 将路径转换为镜像名称 (例如: dotnet/sdk3.1 -> dotnet:sdk3.1)
if ($DirectoryPath -match "[/\\]") {
    # 包含子目录的情况，如 dotnet/sdk3.1
    $PathParts = $DirectoryPath -split "[/\\]"
    $ImageName = $PathParts[0]
    $SubTag = ($PathParts[1..($PathParts.Length-1)] -join "-")
    
    if ($Tag -eq "1.0") {
        # 如果使用默认标签，直接使用子路径作为标签
        $FinalTag = $SubTag
    } else {
        # 如果指定了自定义标签，组合使用
        $FinalTag = "${SubTag}-${Tag}"
    }
} else {
    # 单层目录的情况，如 java
    $ImageName = $DirectoryPath
    $FinalTag = $Tag
}

# 完整的镜像标签
$FullImageTag = "${DockerHost}/${ImageName}:${FinalTag}"

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Docker 构建信息:" -ForegroundColor Green
Write-Host "目录: $DirectoryPath" -ForegroundColor Yellow
Write-Host "Dockerfile: $DockerfilePath" -ForegroundColor Yellow
Write-Host "镜像名称: $ImageName" -ForegroundColor Yellow
Write-Host "标签: $FinalTag" -ForegroundColor Yellow
Write-Host "平台: $Platform" -ForegroundColor Yellow
Write-Host "完整镜像标签: $FullImageTag" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Green

# 询问是否推送到仓库
$Response = Read-Host "是否推送镜像到仓库? (y/N)"

# 根据用户选择构建 docker buildx 命令参数
$BuildxArgs = @(
    "--platform", $Platform,
    "--tag", $FullImageTag,
    "--file", $DockerfilePath
)

if ($Response -match "^[Yy]$") {
    Write-Host "开始构建并推送 Docker 镜像..." -ForegroundColor Cyan
    $BuildxArgs += "--push"
} else {
    Write-Host "开始构建 Docker 镜像（仅本地）..." -ForegroundColor Cyan
}

# 执行构建
try {
    & docker buildx build @BuildxArgs $DirectoryPath
        
    if ($LASTEXITCODE -ne 0) {
        throw "Docker 构建失败"
    }
    
    if ($Response -match "^[Yy]$") {
        Write-Host "构建并推送完成!" -ForegroundColor Green
    } else {
        Write-Host "构建完成!" -ForegroundColor Green
    }
    Write-Host "完整镜像标签: $FullImageTag" -ForegroundColor Yellow
    
    # 自动更新 docker-compose.yml 中的镜像名称
    $DockerComposePath = Join-Path $DirectoryPath "docker-compose.yml"
    if (Test-Path $DockerComposePath) {
        Write-Host "正在更新 docker-compose.yml 中的镜像名称..." -ForegroundColor Cyan
        
        # 读取文件内容
        $ComposeContent = Get-Content $DockerComposePath -Raw
        
        # 使用正则表达式替换 image 字段
        $UpdatedContent = $ComposeContent -replace "(\s+image:\s+)([^\r\n]+)", "`$1$FullImageTag"
        
        # 写回文件
        Set-Content -Path $DockerComposePath -Value $UpdatedContent -NoNewline
        
        Write-Host "✅ 已更新 docker-compose.yml 中的镜像名称为: $FullImageTag" -ForegroundColor Green
    } else {
        Write-Host "⚠️  未找到 docker-compose.yml 文件，跳过镜像名称更新" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "📋 Docker Compose 使用说明:" -ForegroundColor Cyan
    Write-Host "镜像名称已自动更新到 docker-compose.yml 文件中" -ForegroundColor White
    Write-Host "image: $FullImageTag" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    
} catch {
    Write-Error "构建过程中发生错误: $_"
    exit 1
}
