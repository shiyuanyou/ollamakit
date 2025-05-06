#!/bin/bash

# A script to keep Ollama running in memory by periodically sending requests

# 配置变量
debug=0 # 调试模式，1表示开启调试模式，0表示关闭调试模式
# debug=1 # 调试模式，1表示开启调试模式，0表示关闭调试模式

## 模型名称文件
MODEL_NAME_FILE="ping_model_list.txt"

## 日志文件
LOG_FILE="/tmp/ollama_keepalive.log"

## 日志文件大小限制 (单位：KB)
MAX_LOG_SIZE=1024  # 默认1MB

## 请求间隔时间（默认：每4分钟）
minutes=4
seconds=0
INTERVAL=$(echo "60 * ${minutes} + ${seconds}" | bc)

## 运行时间段设置（24小时制）
START_TIME="14:00"  # 默认早上9点开始
END_TIME="17:00"    # 默认晚上11点结束

get_model_name() {
    if [ -f "$MODEL_NAME_FILE" ]; then
        cat "$MODEL_NAME_FILE"
    else
        echo "Error: Model name file not found!"
        exit 1
    fi
}

# 检查当前时间是否在指定时间范围内
is_within_operating_hours() {
    local current_time=$(date +"%H:%M")
    
    # 将时间转换为分钟，以便于比较
    local current_minutes=$(echo "$(date +"%H") * 60 + $(date +"%M")" | bc)
    local start_minutes=$(echo "$(echo $START_TIME | cut -d':' -f1) * 60 + $(echo $START_TIME | cut -d':' -f2)" | bc)
    local end_minutes=$(echo "$(echo $END_TIME | cut -d':' -f1) * 60 + $(echo $END_TIME | cut -d':' -f2)" | bc)
    
    if [ $start_minutes -le $current_minutes ] && [ $current_minutes -le $end_minutes ]; then
        return 0  # 在时间范围内
    else
        return 1  # 不在时间范围内
    fi
}

# 管理日志文件大小
manage_log_file() {
    # 检查日志文件是否存在
    if [ ! -f "$LOG_FILE" ]; then
        return
    fi
    
    # 获取日志文件大小(KB)
    local log_size=$(du -k "$LOG_FILE" | cut -f1)
    
    # 如果日志文件超过最大限制，清空日志文件
    if [ "$log_size" -gt "$MAX_LOG_SIZE" ]; then
        echo "$(date): 日志文件大小 (${log_size}KB) 超过限制 (${MAX_LOG_SIZE}KB)，正在清空..." > "$LOG_FILE"
        echo "$(date): 清空日志文件完成。" >> "$LOG_FILE"
    fi
}

echo "Model name: $(get_model_name)"
echo "运行时间段设置: $START_TIME - $END_TIME" >> "$LOG_FILE"
echo "自动运行间隔: ${minutes}分${seconds}秒 (${INTERVAL}秒)" >> "$LOG_FILE"
echo "日志文件大小限制: ${MAX_LOG_SIZE}KB" >> "$LOG_FILE"
echo "Starting Ollama keep-alive service for models: $(get_model_name)"
echo "Logs will be written to $LOG_FILE"

# 发送请求到Ollama
send_ping() {
    model_names=$(get_model_name)
    for model in $model_names; do
        echo "$(date): Sending ping to Ollama for model: $model" >> "$LOG_FILE"
        if [ $debug -eq 1 ]; then
            echo "Debug mode: Sending ping to Ollama for model: $model" >> "$LOG_FILE"
        else
            echo "hi /no_think" | ollama run "$model" >> "$LOG_FILE" 2>&1
        fi
        echo "$(date): Ping completed for model: $model" >> "$LOG_FILE"
    done
}

# 主循环
while true; do
    # 管理日志文件大小
    manage_log_file
    
    # 检查ollama是否运行
    if ! pgrep -x "ollama" > /dev/null; then
        echo "$(date): Error - Ollama is not running!" >> "$LOG_FILE"
        echo "Please start Ollama first, then run this script."
        exit 1
    fi
    
    # 检查当前是否在指定的运行时间内
    if is_within_operating_hours; then
        echo "$(date): 在运行时间段内，发送ping请求..." >> "$LOG_FILE"
        send_ping
    else
        echo "$(date): 当前时间不在运行时间段($START_TIME-$END_TIME)内，跳过ping请求" >> "$LOG_FILE"
    fi
    
    # 等待下一次间隔
    echo "$(date): Waiting $INTERVAL seconds until next check..." >> "$LOG_FILE"
    sleep "$INTERVAL"
done