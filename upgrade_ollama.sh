#!/bin/bash

llm_list=$(ollama list | tail -n +2 | awk '{print $1}')

for llm in $llm_list; do
  ollama pull $llm
done
