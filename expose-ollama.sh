#!/bin/bash

# 定义 systemd 服务文件路径
SERVICE_FILE="/etc/systemd/system/ollama.service"

# 检查文件是否存在
if [ ! -f "$SERVICE_FILE" ]; then
  echo "错误：Ollama systemd 服务文件未找到：$SERVICE_FILE"
  exit 1
fi

# 使用 sed 命令在 Environment 行后添加一行
sudo sed -i '/^Environment="PATH=/a Environment="OLLAMA_HOST=0.0.0.0:11434"' "$SERVICE_FILE"

# 重新加载 systemd 配置
sudo systemctl daemon-reload

# 重启 Ollama 服务
sudo systemctl restart ollama

# 检查 Ollama 服务状态
sudo systemctl status ollama

echo "Ollama 服务已配置并重启。"
