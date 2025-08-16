FROM python:3.11-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    curl \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

# 安装Python开发工具
RUN pip install --no-cache-dir \
    ipython \
    pytest \
    pytest-cov \
    black \
    flake8 \
    mypy \
    pre-commit

# 设置环境变量
ENV PYTHONPATH=/workspace
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 创建非root用户
RUN useradd -m -s /bin/bash developer && \
    chown -R developer:developer /workspace
USER developer

CMD ["tail", "-f", "/dev/null"]
