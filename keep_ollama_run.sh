#!/bin/bash

# A script to keep Ollama running in memory by periodically sending requests

# const var list

## Set to 1 for debug mode, 0 for normal operation. debug mode will not send actual requests to Ollama.
debug=0

## Model name to use (can be modified as needed)
MODEL_NAME_FILE="ping_model_list.txt"

## Log file for the interactions
LOG_FILE="/tmp/ollama_keepalive.log"

## Interval in seconds between pings (default: 15 minutes)
minutes=4
seconds=0
INTERVAL=$(echo "60 * ${minutes} + seconds" | bc)

get_model_name() {
    if [ -f "$MODEL_NAME_FILE" ]; then
        echo $(cat "$MODEL_NAME_FILE")
    else
        echo "Error: Model name file not found!"
        exit 1
    fi
}

echo "Model name: $(get_model_name)"
echo "auto run after ${minutes} minutes and ${seconds} seconds, which is ${INTERVAL} sec, of idle time to keep Ollama alive " >> "$LOG_FILE"
echo "Starting Ollama keep-alive service for models: $get_model_name"
echo "Logs will be written to $LOG_FILE"

# Function to send a ping to Ollama
send_ping() {
    model_names=$(get_model_name)
    for model in $model_names; do
        echo "$(date): Sending ping to Ollama for model: $model" >> "$LOG_FILE"
        if [ $debug -eq 1 ]; then
            echo "Debug mode: Sending ping to Ollama for model: $model" >> "$LOG_FILE"
        else
            echo "/nothinking hi" | ollama run "$model" >> "$LOG_FILE" 2>&1
        fi
        echo "$(date): Ping completed for model: $model" >> "$LOG_FILE"
    done
}

# Main loop
while true; do
    # Check if ollama is running, if not, exit with error
    if ! pgrep -x "ollama" > /dev/null; then
        echo "$(date): Error - Ollama is not running!" >> "$LOG_FILE"
        echo "Please start Ollama first, then run this script."
        exit 1
    fi
    
    # Send ping
    send_ping
    
    # Wait for next interval
    echo "$(date): Waiting $INTERVAL seconds until next ping..." >> "$LOG_FILE"
    sleep "$INTERVAL"
done