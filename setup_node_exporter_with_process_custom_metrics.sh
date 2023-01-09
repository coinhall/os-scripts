#!/bin/bash
# Requires process command as argument.
# Downloads node_exporter from prometheus.
# Downloads process_custom_metrics_script.py that serves a .prom file for the node_exporter.
# Sets up a cronjob to refresh the .prom file every minute.
# Starts the node_exporter in a tmux session

set -e

if [ $# -lt 1 ]; then
    echo "Requires at least one argument. Argument is the command, ONLY, used to start process without additional arguments/flags."
    exit 1
fi

node_exporter_directory=node_exporter-1.5.0.linux-amd64
prom_script_file=process_custom_metrics_script.py

echo "Changing to home directory..."
cd
echo "Downloading $node_exporter_directory"
if [ -d "$node_exporter_directory" ]; then
    rm -rf $node_exporter_directory
fi
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz -P ~ 
echo "Extracting file..."
tar -xzf node_exporter-1.5.0.linux-amd64.tar.gz
rm -f node_exporter-1.5.0.linux-amd64.tar.gz
echo "$node_exporter_directory downloaded."

echo "Downloading process_custom_metrics_script.py"
if [ -f "$prom_script_file" ]; then
    rm -f $prom_script_file
fi
wget https://raw.githubusercontent.com/coinhall/os-scripts/main/process_custom_metrics_script.py -P ~
echo "$prom_script_file downloaded."

echo "Setting up cronjob..."
(crontab -l || true; echo "*/1 * * * * python3 ~/process_custom_metrics_script.py ${@:1} > ./node_exporter_cron.log 2>&1") | awk '!seen[$0]++' | crontab -
echo "cronjob set up done."

echo "Starting node_exporter in tmux session called node-exporter..."
session_name=node-exporter
session_exist=$(tmux ls | grep $session_name) || session_exist=""
if [ ! "$session_exist" = "" ]; then
    tmux kill-session -t $session_name
fi
tmux new-session -d -s $session_name
tmux send-keys -t $session_name 'cd node_exporter-1.5.0.linux-amd64' C-m
tmux send-keys -t $session_name './node_exporter --collector.textfile.directory="$HOME"' C-m
echo "node_exporter started"