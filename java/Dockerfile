FROM openjdk:17-jdk-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    curl \
    vim \
    nano \
    maven \
    gradle \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

# 设置环境变量
ENV JAVA_HOME=/usr/local/openjdk-17
ENV PATH=$JAVA_HOME/bin:$PATH
ENV MAVEN_HOME=/usr/share/maven
ENV GRADLE_HOME=/usr/share/gradle

# 创建非root用户
RUN useradd -m -s /bin/bash developer && \
    chown -R developer:developer /workspace
USER developer

CMD ["tail", "-f", "/dev/null"]
