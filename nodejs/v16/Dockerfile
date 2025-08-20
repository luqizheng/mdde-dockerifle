FROM zhcoder-docker-registry.com:8000/library/node:v16-slim
RUN sed -i \
    -e 's|http://deb.debian.org/debian|https://mirrors.tuna.tsinghua.edu.cn/debian|g' \
    -e 's|http://security.debian.org|https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' \
    /etc/apt/sources.list.d/debian.sources

# 安装系统依赖
RUN /usr/bin/apt upgrade -y 

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
