FROM zhcoder-docker-registry.com:8000/official/node:14.21.3
# 设置环境变量
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

# Set archive repositories for Buster
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt update && \
    apt upgrade -y
    
# 安装系统依赖
RUN /usr/bin/apt upgrade -y 
RUN /usr/bin/apt install -y \
    curl \
    wget \
    unzip \
    zip \
    tree \
    htop \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace
RUN npm config set registry http://192.168.2.8:8081/repository/npm-group/
# 全局安装常用开发工具
RUN npm install -g \
    typescript \
    ts-node \
    @types/node \
    nrm 

# 设置环境变量
ENV NODE_ENV=development
ENV CHOKIDAR_USEPOLLING=true

# 创建非root用户
# RUN groupadd -g 1001 nodejs && \
#     useradd -r -u 1001 -g nodejs nodejs && \
#     chown -R nodejs:nodejs /workspace
USER root

CMD ["tail", "-f", "/dev/null"]
