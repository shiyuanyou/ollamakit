#!/bin/bash

model_name="qwen3:30b-a3b"

# both update and install
curl -fsSL https://ollama.com/install.sh | sh

# auto listen 0.0.0.0:11434 instead of 127.0.0.1:11434
./expose-ollama.sh

# run 
ollama run ${model_name} --verbose
