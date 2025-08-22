FROM zhcoder-docker-registry.com:8000/official/library/openjdk:8-jdk

# 设置环境变量
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装系统依赖和开发工具
RUN apt-get update && apt-get install -y \
    # 基础工具
    curl \
    wget \
    unzip \
    zip \
    tree \
    htop \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*
# 使用 curl 下载并安装 Maven（推荐 3.8.6 版本，可根据需要修改）
RUN mkdir -p /opt/maven && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | \
    tar -xzC /opt/maven --strip-components=1


# 配置 Maven 镜像源（阿里云）
RUN mkdir -p /opt/maven/conf && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | \
    tar -xzC /opt/maven --strip-components=1 && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' > /opt/maven/conf/settings.xml && \
    echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"' >> /opt/maven/conf/settings.xml && \
    echo '          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' >> /opt/maven/conf/settings.xml && \
    echo '          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0' >> /opt/maven/conf/settings.xml && \
    echo '                              https://maven.apache.org/xsd/settings-1.0.0.xsd">' >> /opt/maven/conf/settings.xml && \
    echo '  <mirrors>' >> /opt/maven/conf/settings.xml && \
    echo '    <mirror>' >> /opt/maven/conf/settings.xml && \
    echo '      <id>aliyunmaven</id>' >> /opt/maven/conf/settings.xml && \
    echo '      <mirrorOf>*</mirrorOf>' >> /opt/maven/conf/settings.xml && \
    echo '      <name>阿里云公共仓库</name>' >> /opt/maven/conf/settings.xml && \
    echo '      <url>https://maven.aliyun.com/repository/public</url>' >> /opt/maven/conf/settings.xml && \
    echo '    </mirror>' >> /opt/maven/conf/settings.xml && \
    echo '  </mirrors>' >> /opt/maven/conf/settings.xml && \
    echo '</settings>' >> /opt/maven/conf/settings.xml

# 安装 Gradle（使用较新版本）
RUN curl -fsSL https://mirrors.cloud.tencent.com/gradle/gradle-7.6.2-bin.zip -o gradle.zip && \
    mkdir -p /opt/gradle && \
    unzip gradle.zip -d /opt/gradle && \
    rm gradle.zip

# 配置 Gradle 镜像源
RUN mkdir -p /root/.gradle && \
    echo 'allprojects {' > /root/.gradle/init.gradle && \
    echo '    repositories {' >> /root/.gradle/init.gradle && \
    echo '        mavenLocal()' >> /root/.gradle/init.gradle && \
    echo '        maven { url "https://maven.aliyun.com/repository/public" }' >> /root/.gradle/init.gradle && \
    echo '        maven { url "https://maven.aliyun.com/repository/central" }' >> /root/.gradle/init.gradle && \
    echo '        maven { url "https://maven.aliyun.com/repository/gradle-plugin" }' >> /root/.gradle/init.gradle && \
    echo '        gradlePluginPortal()' >> /root/.gradle/init.gradle && \
    echo '        mavenCentral()' >> /root/.gradle/init.gradle && \
    echo '    }' >> /root/.gradle/init.gradle && \
    echo '}' >> /root/.gradle/init.gradle

# 设置环境变量
ENV MAVEN_HOME=/opt/maven \
    GRADLE_HOME=/opt/gradle/gradle-7.6.2 \
    PATH=$PATH:/opt/maven/bin:/opt/gradle/gradle-7.6.2/bin



# 创建开发用户（非 root）
RUN groupadd -r developer && useradd -r -g developer developer && \
    mkdir -p /home/developer && chown developer:developer /home/developer && \
    mkdir -p /workspace && chown developer:developer /workspace

# 复制 Maven 配置到用户目录
RUN mkdir -p /home/developer/.m2 && \
    cp /opt/maven/conf/settings.xml /home/developer/.m2/ && \
    chown -R developer:developer /home/developer/.m2

# 复制 Gradle 配置到用户目录
RUN mkdir -p /home/developer/.gradle && \
    cp /root/.gradle/init.gradle /home/developer/.gradle/ && \
    chown -R developer:developer /home/developer/.gradle

# 设置工作目录
WORKDIR /workspace

# 切换到开发用户
USER developer

# 设置 Java 工具选项
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

CMD ["tail", "-f", "/dev/null"]
