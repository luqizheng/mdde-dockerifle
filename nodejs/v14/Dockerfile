FROM zhcoder-docker-registry.com:8000/official/node:14.21.3
# 设置环境变量
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN echo "Types: deb" > /etc/apt/sources.list.d/tuna.sources && \
    echo "URIs: https://mirrors.tuna.tsinghua.edu.cn/debian" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "Suites: bookworm bookworm-updates bookworm-backports" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "Components: main contrib non-free non-free-firmware" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "Types: deb" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "URIs: https://mirrors.tuna.tsinghua.edu.cn/debian-security" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "Suites: bookworm-security" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "Components: main contrib non-free non-free-firmware" >> /etc/apt/sources.list.d/tuna.sources && \
    echo "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" >> /etc/apt/sources.list.d/tuna.sources
# 安装系统依赖
RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y nano iputils-ping vim telnet \
    net-tools \
    lsof \
    nmap \
    curl \
    tree \
    htop \
    iputils-ping \
    nano \
    telnet\
    lsof\
    net-tools\
    jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

# 全局安装常用开发工具
RUN npm install -g \
    typescript \
    ts-node \
    @types/node \
    nrm 
RUN nrm add local  http://192.168.2.8:8081/repository/npm-group/ \
    && nrm add pub  http://192.168.2.8:8081/repository/coder-npm-host/

# 设置环境变量
ENV NODE_ENV=development
ENV CHOKIDAR_USEPOLLING=true

# 创建非root用户
# RUN groupadd -g 1001 nodejs && \
#     useradd -r -u 1001 -g nodejs nodejs && \
#     chown -R nodejs:nodejs /workspace
USER root

CMD ["tail", "-f", "/dev/null"]
