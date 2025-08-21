#!/usr/bin/env pwsh

<#
.SYNOPSIS
    扫描当前目录下的子目录并生成JSON索引文件
.DESCRIPTION
    此脚本会递归扫描当前目录，找到包含Dockerfile的目录，
    并将这些目录路径生成到JSON文件中
.PARAMETER OutputFile
    输出JSON文件的路径，默认为 "build-index.json"
.EXAMPLE
    .\build-index.ps1
    .\build-index.ps1 -OutputFile "custom-index.json"
#>

param(
    [string]$OutputFile = "index.json"
)

# 设置错误处理
$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Find-DockerDirectories {
    <#
    .SYNOPSIS
        查找包含Dockerfile的目录
    #>
    param(
        [string]$BasePath = "."
    )
    
    $dockerDirs = @()
    
    try {
        # 递归查找包含Dockerfile的目录
        $dockerfiles = Get-ChildItem -Path $BasePath -Recurse -Filter "Dockerfile*" -File | Where-Object {
            $_.Name -match "^[Dd]ockerfile.*$"
        }
        
        foreach ($dockerfile in $dockerfiles) {
            $dirPath = $dockerfile.Directory.FullName
            $relativePath = (Resolve-Path -Path $dirPath -Relative).TrimStart(".\").Replace("\", "/")
            
            # 跳过根目录
            if ($relativePath -ne "." -and $relativePath -ne "") {
                $dockerDirs += $relativePath
            }
        }
        
        # 去重并排序
        $dockerDirs = $dockerDirs | Sort-Object -Unique
        
        return $dockerDirs
    }
    catch {
        Write-ColorOutput "Error scanning directories: $($_.Exception.Message)" "Red"
        throw
    }
}

function Write-JsonIndex {
    <#
    .SYNOPSIS
        将目录列表写入JSON文件
    #>
    param(
        [string[]]$Directories,
        [string]$FilePath
    )
    
    try {
        # 生成JSON内容
        $jsonContent = $Directories | ConvertTo-Json -Depth 2
        
        # 写入文件
        $jsonContent | Out-File -FilePath $FilePath -Encoding UTF8
        
        Write-ColorOutput "JSON index file generated: $FilePath" "Green"
        Write-ColorOutput "Found $($Directories.Count) Docker build directories" "Cyan"
        
        # 显示找到的目录
        if ($Directories.Count -gt 0) {
            Write-ColorOutput "Included directories:" "Yellow"
            foreach ($dir in $Directories) {
                Write-ColorOutput "   - $dir" "White"
            }
        }
    }
    catch {
        Write-ColorOutput "Error writing JSON file: $($_.Exception.Message)" "Red"
        throw
    }
}

# 主程序
try {
    Write-ColorOutput "Starting directory scan..." "Cyan"
    Write-ColorOutput "Current working directory: $(Get-Location)" "Gray"
    
    # 查找包含Dockerfile的目录
    $directories = Find-DockerDirectories
    
    if ($directories.Count -eq 0) {
        Write-ColorOutput "No directories containing Dockerfile found" "Yellow"
        $directories = @()
    }
    
    # 生成JSON索引文件
    Write-JsonIndex -Directories $directories -FilePath $OutputFile
    
    Write-ColorOutput "Index generation completed!" "Green"
}
catch {
    Write-ColorOutput "Script execution failed: $($_.Exception.Message)" "Red"
    exit 1
}
