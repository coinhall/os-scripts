#!/bin/bash

set -e

if [ $# -lt 1 ]; then
    echo "Requires one argument. Argument is the chain specific command."
    exit 1
elif [ $# -gt 1 ]; then
    echo "Please specify only one argument."
    exit 1
fi

echo "Changing to home directory..."
cd
echo "Downloading node_exporter-1.4.0.linux-amd4"
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz -P ~ 
echo "Extracting file..."
tar -xzf node_exporter-1.4.0.linux-amd64.tar.gz
rm -f node_exporter-1.4.0.linux-amd64.tar.gz

echo "Downloading node_status_prom_script.py"
wget https://raw.githubusercontent.com/coinhall/os-scripts/main/node_status_prom_script.py -P ~

echo "Setting up cronjob..."
crontab -l; echo "*/1 * * * * python3 ~/node_status_prom_script.py $1 > ./node_exporter_cron.log 2>&1" | awk '!seen[$0]++' | crontab -