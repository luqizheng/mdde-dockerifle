#!/usr/bin/env pwsh

# 检查环境配置文件
if (-not (Test-Path ".dev.env")) {
    Write-Host "错误: 未找到 .dev.env 配置文件，请先运行 create-dev-env.ps1" -ForegroundColor Red
    exit 1
}

# 加载环境变量
Get-Content ".dev.env" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.*)$") {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

$containerName = $env:CONTAINER_NAME
if ([string]::IsNullOrEmpty($containerName)) {
    $containerName = "java-dev"
}

# 检查容器是否运行
$containerStatus = docker ps --filter "name=$containerName" --format "{{.Status}}"
if ([string]::IsNullOrEmpty($containerStatus)) {
    Write-Host "错误: 容器 $containerName 未运行，请先启动开发环境" -ForegroundColor Red
    exit 1
}

# 获取命令参数
$command = $args -join " "
if ([string]::IsNullOrEmpty($command)) {
    Write-Host "用法: .\run-cmd.ps1 <命令>" -ForegroundColor Yellow
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "  .\run-cmd.ps1 mvn clean install" -ForegroundColor Cyan
    Write-Host "  .\run-cmd.ps1 mvn spring-boot:run" -ForegroundColor Cyan
    Write-Host "  .\run-cmd.ps1 gradle build" -ForegroundColor Cyan
    Write-Host "  .\run-cmd.ps1 java -jar target/app.jar" -ForegroundColor Cyan
    Write-Host "  .\run-cmd.ps1 mvn test" -ForegroundColor Cyan
    exit 1
}

Write-Host "在容器 $containerName 中执行: $command" -ForegroundColor Green
docker exec -it $containerName $command
