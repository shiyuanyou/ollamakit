# OllamaKit

更好地使用Ollama

- `expose-ollama.sh`：将Ollama更新为允许外部设备网络访问，监听`0.0.0.0:11434`而非仅限本地`127.0.0.1:11434`
- `update-ollama-test-qwen3.sh`：更新Ollama并测试`qwen3:30b-a3b`模型，也可用于初次下载Ollama时自动安装qwen3
    - 通过修改`model_name`变量可下载其他Ollama模型
    - `-t`通过参数来控制是否在更新ollama后自动开启测试，
- `upgrade_ollama.sh`：自动更新所有已安装模型
- `keep_ollama_run.sh`：定时向Ollama发送ping请求，防止内存卸载。可使用`nohup ./keep_ollama_run.sh &`在后台运行
    - 使用前请查看脚本开头的变量设置，可通过设置`debug=0`进行调试
    - 日志文件位于`/tmp/ollama_keepalive.log`
    - 需要保持活跃的模型列表存储在`ping_model_list.txt`中，可动态调整，每次发送ping请求前会重新读取该文件
