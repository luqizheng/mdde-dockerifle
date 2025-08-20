# MDDE Dockerfile 开发环境

一个用于快速构建各种开发环境 Docker 镜像的项目，支持多种编程语言和框架的开发环境配置。

## 📋 项目概述

本项目提供了预配置的 Dockerfile 和构建脚本，帮助开发者快速创建标准化的开发环境镜像，包括：

- .NET Core 开发环境
- Node.js 开发环境
- Java 开发环境
- Python 开发环境

## 🛠️ 技术栈

- **Docker & Docker Buildx** - 容器化和多平台构建
- **Shell Script** - Linux/Mac 构建脚本
- **PowerShell** - Windows 构建脚本

## 📁 项目结构

```
mdde-dockerfile/
├── build.config              # 构建配置文件
├── build.sh                  # Linux/Mac 构建脚本
├── build.ps1                 # Windows 构建脚本
├── README.md                 # 项目说明文档
├── dotnet/                   # .NET 开发环境
│   ├── sdk3.1/              # .NET Core 3.1 SDK
│   └── sdk9/                # .NET 9 SDK
├── java/                     # Java 开发环境
│   └── Dockerfile           # Java 17 JDK
├── nodejs/                   # Node.js 开发环境
│   ├── v16/                 # Node.js 16
│   └── v22/                 # Node.js 22
└── python/                   # Python 开发环境
    └── yolo-11/             # Python with YOLO 11
```

## ⚙️ 配置文件

### `build.config`

```ini
# 推送的 docker-image 的地址
docker-host=zhcoder-docker-registry.com:8000/dev-env

# 目标平台
platform=linux/amd64
```

**配置说明：**
- `docker-host`: Docker 镜像仓库地址
- `platform`: 目标构建平台（支持多平台构建）

## 🚀 使用说明

### Linux/Mac 环境

```bash
# 赋予执行权限
chmod +x build.sh

# 构建镜像（使用默认标签 1.0）
./build.sh dotnet/sdk3.1

# 构建镜像并指定标签
./build.sh nodejs/v16 1.1

# 构建 Java 环境
./build.sh java

# 构建 Python YOLO 环境
./build.sh python/yolo-11 2.0
```

### Windows 环境

```powershell
# 构建镜像（使用默认标签 1.0）
.\build.ps1 dotnet/sdk3.1

# 构建镜像并指定标签
.\build.ps1 nodejs/v16 1.1

# 构建 Java 环境
.\build.ps1 java

# 构建 Python YOLO 环境
.\build.ps1 python/yolo-11 2.0
```

## 📖 构建脚本功能

### 核心功能
- ✅ **自动配置读取** - 从 `build.config` 读取仓库地址和平台信息
- ✅ **智能路径检测** - 自动检测 Dockerfile 位置
- ✅ **镜像名称生成** - 根据目录路径自动生成镜像名称
- ✅ **多平台构建** - 支持通过 Docker Buildx 进行多平台构建
- ✅ **可选推送** - 构建完成后可选择是否推送到仓库
- ✅ **错误处理** - 完整的错误检查和友好提示
- ✅ **Compose 提示** - 构建完成后显示 docker-compose.yml 中的镜像名称

### 镜像命名规则

构建脚本会根据目录路径自动生成镜像名称和标签：

| 目录路径 | 镜像名称 | 默认标签 | 完整标签示例 |
|---------|---------|---------|-------------|
| `dotnet/sdk3.1` | `dotnet` | `sdk3.1` | `zhcoder-docker-registry.com:8000/dev-env/dotnet:sdk3.1` |
| `nodejs/v16` | `nodejs` | `v16` | `zhcoder-docker-registry.com:8000/dev-env/nodejs:v16` |
| `java` | `java` | `1.0` | `zhcoder-docker-registry.com:8000/dev-env/java:1.0` |
| `python/yolo-11` | `python` | `yolo-11` | `zhcoder-docker-registry.com:8000/dev-env/python:yolo-11` |

**标签规则说明：**
- **默认标签（tag=1.0）**：使用子路径作为标签，如 `dotnet/sdk3.1` → `dotnet:sdk3.1`
- **自定义标签**：组合子路径和自定义标签，如 `./build.sh dotnet/sdk3.1 2.0` → `dotnet:sdk3.1-2.0`
- **单层目录**：直接使用指定标签，如 `./build.sh java 1.5` → `java:1.5`

## 🔧 开发环境说明

### .NET Core 环境

**支持版本：**
- .NET Core 3.1 (`dotnet/sdk3.1/`)
- .NET 9 (`dotnet/sdk9/`)

**包含功能：**
- 完整的 .NET SDK
- 开发工具和运行时
- NuGet 包管理配置
- 非 root 用户设置

### Node.js 环境

**支持版本：**
- Node.js 16 (`nodejs/v16/`)
- Node.js 22 (`nodejs/v22/`)

**包含功能：**
- Node.js 运行时和 npm
- TypeScript 全局工具
- 常用开发工具包
- 自定义 npm 源配置

### Java 环境

**版本：** OpenJDK 17

**包含功能：**
- Java 17 JDK
- Maven 构建工具
- Gradle 构建工具
- 常用开发工具

### Python 环境

**专用环境：** YOLO 11 机器学习环境

**包含功能：**
- Python 运行时
- YOLO 11 相关依赖
- 机器学习开发工具

## 🔄 构建流程

1. **参数验证** - 检查输入参数和文件存在性
2. **配置读取** - 从 `build.config` 读取配置信息
3. **环境检查** - 验证 Docker 和 Buildx 可用性
4. **用户确认** - 询问是否推送到远程仓库
5. **镜像构建** - 执行 Docker Buildx 构建
6. **结果输出** - 显示构建结果和镜像信息
7. **Compose 提示** - 显示 docker-compose.yml 中应使用的镜像名称

## 📝 使用示例

### 快速开始

```bash
# 1. 克隆项目
git clone <repository-url>
cd mdde-dockerfile

# 2. 配置构建参数（可选，使用默认配置）
vim build.config

# 3. 构建 .NET 开发环境（生成 dotnet:sdk3.1）
./build.sh dotnet/sdk3.1

# 4. 构建完成后选择是否推送
# 是否推送镜像到仓库? (y/N): y

# 5. 构建完成后会显示使用说明
# =========================================
# 📋 Docker Compose 使用说明:
# 在 docker-compose.yml 中使用以下镜像名称:
# image: zhcoder-docker-registry.com:8000/dev-env/dotnet:sdk3.1
# =========================================
```

### 构建示例

```bash
# 使用默认标签构建（推荐）
./build.sh dotnet/sdk3.1          # → dotnet:sdk3.1
./build.sh nodejs/v16             # → nodejs:v16
./build.sh java                   # → java:1.0
./build.sh python/yolo-11         # → python:yolo-11

# 使用自定义标签构建
./build.sh dotnet/sdk3.1 2.0      # → dotnet:sdk3.1-2.0
./build.sh nodejs/v16 dev         # → nodejs:v16-dev
./build.sh java 1.5               # → java:1.5
```

## ⚠️ 注意事项

1. **Docker Buildx 要求** - 确保系统已安装 Docker Buildx
2. **仓库权限** - 推送镜像需要对目标仓库有写入权限
3. **网络环境** - 构建过程需要良好的网络连接
4. **存储空间** - 确保有足够的磁盘空间进行构建

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来改进项目：

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/your-feature`)
3. 提交更改 (`git commit -am 'Add some feature'`)
4. 推送到分支 (`git push origin feature/your-feature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 🔗 相关链接

- [Docker Buildx 文档](https://docs.docker.com/buildx/)
- [多平台构建指南](https://docs.docker.com/build/building/multi-platform/)
- [Docker 最佳实践](https://docs.docker.com/develop/dev-best-practices/)
