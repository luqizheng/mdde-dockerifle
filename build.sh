#!/bin/bash

# Docker 构建脚本
# 使用方式: ./build.sh <directory_path> [tag]
# 示例: ./build.sh dotnet/sdk3.1
# 示例: ./build.sh nodejs/v16 1.1

set -e

# 检查参数
if [ $# -lt 1 ]; then
    echo "使用方式: $0 <directory_path> [tag]"
    echo "示例: $0 dotnet/sdk3.1"
    echo "示例: $0 nodejs/v16 1.1"
    exit 1
fi

DIRECTORY_PATH="$1"
TAG="${2:-1.0}"

# 读取配置文件
CONFIG_FILE="build.config"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 配置文件 $CONFIG_FILE 不存在"
    exit 1
fi

# 解析配置文件
DOCKER_HOST=$(grep "^docker-host=" "$CONFIG_FILE" | cut -d'=' -f2)
PLATFORM=$(grep "^platform=" "$CONFIG_FILE" | cut -d'=' -f2)

if [ -z "$DOCKER_HOST" ] || [ -z "$PLATFORM" ]; then
    echo "错误: 配置文件中缺少必要参数"
    exit 1
fi

# 检查目录是否存在
if [ ! -d "$DIRECTORY_PATH" ]; then
    echo "错误: 目录 $DIRECTORY_PATH 不存在"
    exit 1
fi

# 检查 Dockerfile 是否存在
DOCKERFILE_PATH=""
if [ -f "$DIRECTORY_PATH/Dockerfile" ]; then
    DOCKERFILE_PATH="$DIRECTORY_PATH/Dockerfile"
elif [ -f "$DIRECTORY_PATH/dockerfile" ]; then
    DOCKERFILE_PATH="$DIRECTORY_PATH/dockerfile"
else
    echo "错误: 在 $DIRECTORY_PATH 中找不到 Dockerfile 或 dockerfile"
    exit 1
fi

# 生成镜像名称和标签
# 将路径转换为镜像名称 (例如: dotnet/sdk3.1 -> dotnet:sdk3.1)
if [[ "$DIRECTORY_PATH" == *"/"* ]]; then
    # 包含子目录的情况，如 dotnet/sdk3.1
    IMAGE_NAME=$(echo "$DIRECTORY_PATH" | cut -d'/' -f1)
    SUB_TAG=$(echo "$DIRECTORY_PATH" | cut -d'/' -f2- | sed 's|/|-|g')
    if [ "$TAG" == "1.0" ]; then
        # 如果使用默认标签，直接使用子路径作为标签
        FINAL_TAG="$SUB_TAG"
    else
        # 如果指定了自定义标签，组合使用
        FINAL_TAG="${SUB_TAG}-${TAG}"
    fi
else
    # 单层目录的情况，如 java
    IMAGE_NAME="$DIRECTORY_PATH"
    FINAL_TAG="$TAG"
fi

# 完整的镜像标签
FULL_IMAGE_TAG="${DOCKER_HOST}/${IMAGE_NAME}:${FINAL_TAG}"

echo "========================================="
echo "Docker 构建信息:"
echo "目录: $DIRECTORY_PATH"
echo "Dockerfile: $DOCKERFILE_PATH"
echo "镜像名称: $IMAGE_NAME"
echo "标签: $FINAL_TAG"
echo "平台: $PLATFORM"
echo "完整镜像标签: $FULL_IMAGE_TAG"
echo "========================================="

# 执行构建
# 询问是否推送到仓库
read -p "是否推送镜像到仓库? (y/N): " -n 1 -r
echo

# 根据用户选择构建 docker buildx 命令参数
BUILDX_ARGS="--platform $PLATFORM --tag $FULL_IMAGE_TAG --file $DOCKERFILE_PATH"

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "开始构建并推送 Docker 镜像..."
    BUILDX_ARGS="$BUILDX_ARGS --push"
else
    echo "开始构建 Docker 镜像（仅本地）..."
fi

# 执行构建
docker buildx build $BUILDX_ARGS "$DIRECTORY_PATH"

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "构建并推送完成!"
else
    echo "构建完成!"
fi
echo "完整镜像标签: $FULL_IMAGE_TAG"

# 自动更新 docker-compose.yml 中的镜像名称
DOCKER_COMPOSE_PATH="$DIRECTORY_PATH/docker-compose.yml"
if [ -f "$DOCKER_COMPOSE_PATH" ]; then
    echo "正在更新 docker-compose.yml 中的镜像名称..."
    
    # 使用 sed 替换 image 字段，保持缩进
    sed -i.bak "s|\([[:space:]]*image:[[:space:]]*\).*|\1$FULL_IMAGE_TAG|" "$DOCKER_COMPOSE_PATH"
    
    # 删除备份文件
    rm -f "$DOCKER_COMPOSE_PATH.bak"
    
    echo "✅ 已更新 docker-compose.yml 中的镜像名称为: $FULL_IMAGE_TAG"
else
    echo "⚠️  未找到 docker-compose.yml 文件，跳过镜像名称更新"
fi

echo ""
echo "========================================="
echo "📋 Docker Compose 使用说明:"
echo "镜像名称已自动更新到 docker-compose.yml 文件中"
echo "image: $FULL_IMAGE_TAG"
echo "========================================="
