#!/bin/bash
# Installs latest Go. Script is idempotent and can be run multiple times to update Go if needed.
# Run script without `sudo`!

set -e

echo "Checking latest Go version..."
latest_go_version="$(curl --silent https://go.dev/VERSION?m=text)"
go_tar_file="$latest_go_version.linux-amd64.tar.gz"
go_download_url="https://golang.org/dl/$go_tar_file"
echo "Latest Go version: $latest_go_version."

echo "Changing to home directory..."
cd
echo "Downloading $go_download_url"
rm -f ~/$go_tar_file
wget $go_download_url -P ~
echo "Extracting file and installing Go..."
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf ~/$go_tar_file
rm -f ~/$go_tar_file

echo "Updating paths and ~/.profile ..."
go_bin="export PATH=$PATH:/usr/local/go/bin"
grep -qxF "$go_bin" ~/.profile || echo $go_bin >>~/.profile
source ~/.profile
go_path="export PATH=$PATH:$(go env GOPATH)/bin"
grep -qxF "$go_path" ~/.profile || echo $go_path >>~/.profile
source ~/.profile

echo "Installed $(go version)!"
echo "NOTE: run 'source ~/.profile' if the 'go' command does not work."
