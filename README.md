# ollamakit

更好的使用ollama

- `expose-ollama.sh` : 把ollama更新为只是外部设备网络访问，监听`0.0.0.0:11434`而不是`127.0.0.1:11434`
- `update-ollama-test-qwen3.sh` : 更新ollama并测试`qwen3:30b-a3b`，也可以用于下载ollama并直接自动下载qwen3
    - 也可通过改`model_name`变量，来下载使用ollama模型
- `upgrade_ollama.sh` : 自动更新所有模型
- `keep_ollama_run.sh` : 向ollama自动定时发ping，避免内存卸载。 可以用 `nohup ./keep_ollama_run.sh &` 在后台运行。
    - 注意查看脚本前的变脸列表，可以通过设置`debug=0`，来自己调试一下。
    - 日志在`/tmp/ollama_keepalive.log`
    - 自动发ping的模型列表在`ping_model_list.txt`，可以动态调整，每次发ping前重新读文件
