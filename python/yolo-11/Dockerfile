#FROM nvidia/cuda:12.1-devel-ubuntu22.04
FROM zhcoder-docker-registry.com:8000/official/cuda:12.1.0-devel-ubuntu20.04
# 设置非交互式安装
ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
# 安装Python和系统依赖
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    git \
    curl \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    libgtk-3-0 \
    && ln -s /usr/bin/python3.11 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

RUN pip instal -i http://192.168.2.8:8081/repository/pip/
# 升级pip
RUN python -m pip install --upgrade pip

# 安装PyTorch with CUDA支持
RUN pip install --no-cache-dir \
    torch==2.1.0 \
    torchvision==0.16.0 \
    torchaudio==2.1.0 \
    --index-url https://download.pytorch.org/whl/cu121

# 安装YOLO和相关依赖
RUN pip install --no-cache-dir \
    ultralytics \
    opencv-python \
    Pillow \
    numpy \
    matplotlib \
    seaborn \
    pandas \
    scipy \
    tqdm \
    psutil

# 安装Python开发工具
RUN pip install --no-cache-dir \
    ipython \
    jupyter \
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
