#!/bin/bash

echo "===== SYSTEM HEALTH CHECK ====="
echo "Date: $(date)"
echo

echo "CPU:"
echo "Load average: $(uptime | awk -F'load average:' '{print $2}')"
echo "Cores: $(nproc)"
echo

echo "Memory:"
free -h
echo

echo "Disk:"
df -h /
echo

echo "Top processes (CPU):"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
echo

echo "Top processes (RAM):"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6
echo
