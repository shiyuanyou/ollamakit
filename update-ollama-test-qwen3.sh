#!/bin/bash

model_name="qwen3:30b-a3b"

# both update and install
curl -fsSL https://ollama.com/install.sh | sh
echo "Ollama 已安装"

# auto listen 0.0.0.0:11434 instead of 127.0.0.1:11434
./expose-ollama.sh
echo "Ollama 服务已自动开放监听外部访问"

# 检查是否有 -t 参数
run_model=false
for arg in "$@"; do
  if [ "$arg" = "-t" ]; then
    run_model=true
    break
  fi
done

# 如果有 -t 参数，则运行模型
if [ "$run_model" = true ]; then
  echo "模型名称: $model_name"
  ollama run ${model_name} --verbose
fi
