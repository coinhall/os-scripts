#!/bin/bash
# Installs specific Go version. Script is idempotent and can be run multiple times to update Go if needed.
# Only for linux x86
# Run script without `sudo`!

set -e

if [ $# -ne 1 ]; then
    echo "Requires one argument that is the version of Go that you want to install."
    exit 1
fi

echo "$1"

echo "Go version to download: $1"
echo ""
go_tar_file="go$1.linux-amd64.tar.gz"
go_download_url="https://golang.org/dl/$go_tar_file"

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
