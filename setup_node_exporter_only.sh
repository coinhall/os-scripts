#!/bin/bash
# Downloads node_exporter from prometheus.
# Starts the node_exporter in a tmux session

set -e

node_exporter_directory=node_exporter-1.5.0.linux-amd64

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