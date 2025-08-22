#!/bin/bash

# build-index.sh
# 扫描当前目录下的子目录并生成JSON索引文件
# 
# 用法:
#   ./build-index.sh [输出文件名]
# 
# 示例:
#   ./build-index.sh                    # 输出到 build-index.json
#   ./build-index.sh custom-index.json  # 输出到 custom-index.json

set -euo pipefail

# 默认输出文件
OUTPUT_FILE="${1:-index.json}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 查找包含Dockerfile的目录并构建对象信息
find_docker_directories() {
    local base_path="${1:-.}"
    local -A processed_paths
    
    print_color "$CYAN" "🔍 扫描目录中..."
    
    # 使用find命令查找所有Dockerfile文件
    while IFS= read -r -d '' dockerfile; do
        # 获取包含Dockerfile的目录路径
        local dir_path=$(dirname "$dockerfile")
        
        # 转换为相对路径
        local relative_path=$(realpath --relative-to="$base_path" "$dir_path")
        
        # 跳过根目录和已处理的路径
        if [[ "$relative_path" != "." && "$relative_path" != "" && -z "${processed_paths[$relative_path]}" ]]; then
            processed_paths["$relative_path"]=1
            
            # 读取描述文件
            local desc_file="$dir_path/desc.txt"
            local description=""
            
            if [[ -f "$desc_file" ]]; then
                # 读取desc.txt内容并去除首尾空格
                description=$(cat "$desc_file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '\n\r')
            fi
            
            # 输出JSON对象格式（临时格式，后续会处理）
            echo "${relative_path}|${description}"
        fi
    done < <(find "$base_path" -name "[Dd]ockerfile*" -type f -print0) | sort
}

# 生成JSON文件
generate_json_index() {
    local directory_data=("$@")
    local json_content="["
    
    # 构建JSON对象数组
    if [[ ${#directory_data[@]} -gt 0 ]]; then
        for i in "${!directory_data[@]}"; do
            if [[ $i -gt 0 ]]; then
                json_content+=","
            fi
            
            # 解析 name|description 格式
            local item="${directory_data[$i]}"
            local name="${item%%|*}"
            local description="${item#*|}"
            
            # 转义JSON特殊字符
            description=$(echo "$description" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n')
            description=${description%\\n}  # 移除最后的\n
            
            json_content+="\n  {\n    \"name\": \"$name\",\n    \"description\": \"$description\"\n  }"
        done
        json_content+="\n"
    fi
    
    json_content+="]"
    
    # 写入文件
    echo -e "$json_content" > "$OUTPUT_FILE"
}

# 显示结果
show_results() {
    local directory_data=("$@")
    local count=${#directory_data[@]}
    
    print_color "$GREEN" "✅ JSON索引文件已生成: $OUTPUT_FILE"
    print_color "$CYAN" "📁 找到 $count 个Docker构建目录"
    
    if [[ $count -gt 0 ]]; then
        print_color "$YELLOW" "\n📋 包含的目录:"
        for item in "${directory_data[@]}"; do
            # 解析 name|description 格式
            local name="${item%%|*}"
            local description="${item#*|}"
            
            if [[ -n "$description" ]]; then
                print_color "$GRAY" "   - $name - $description"
            else
                print_color "$GRAY" "   - $name"
            fi
        done
    fi
}

# 错误处理函数
error_exit() {
    local message=$1
    print_color "$RED" "❌ 错误: $message"
    exit 1
}

# 主程序
main() {
    print_color "$CYAN" "🔍 开始扫描目录..."
    print_color "$GRAY" "📂 当前工作目录: $(pwd)"
    
    # 检查当前目录是否存在
    if [[ ! -d "." ]]; then
        error_exit "当前目录不存在"
    fi
    
    # 查找包含Dockerfile的目录
    local directories_output
    directories_output=$(find_docker_directories ".")
    
    # 将输出转换为数组
    local directory_data=()
    if [[ -n "$directories_output" ]]; then
        while IFS= read -r line; do
            directory_data+=("$line")
        done <<< "$directories_output"
    fi
    
    # 检查是否找到目录
    if [[ ${#directory_data[@]} -eq 0 ]]; then
        print_color "$YELLOW" "⚠️  未找到包含Dockerfile的目录"
    fi
    
    # 生成JSON索引文件
    generate_json_index "${directory_data[@]}" || error_exit "生成JSON文件失败"
    
    # 显示结果
    show_results "${directory_data[@]}"
    
    print_color "$GREEN" "\n🎉 索引生成完成!"
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
