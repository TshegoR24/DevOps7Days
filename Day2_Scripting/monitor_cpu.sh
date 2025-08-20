#!/bin/bash
# Logs CPU usage every 5 seconds
while true
do
  echo "$(date) - CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%" >> cpu_log.txt
  sleep 5
done
