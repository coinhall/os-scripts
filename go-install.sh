#!/bin/bash

printf "Checking latest Go version...\n";
LATEST_GO_VERSION="$(curl --silent https://go.dev/VERSION?m=text)";
LATEST_GO_DOWNLOAD_URL="https://golang.org/dl/${LATEST_GO_VERSION}.linux-amd64.tar.gz"
printf "Latest Go version is ${LATEST_GO_VERSION}.\n"

printf "cd to $HOME directory\n"
cd $HOME

printf "Downloading ${LATEST_GO_DOWNLOAD_URL}\n\n";
wget https://golang.org/dl/${LATEST_GO_VERSION}.linux-amd64.tar.gz -P $HOME
printf "Extracting file and installing Go...\n"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $HOME/${LATEST_GO_VERSION}.linux-amd64.tar.gz

printf "Updating paths and .profile ...\n"
echo "export PATH=$PATH:/usr/local/go/bin" >> $HOME/.profile
source ~/.profile
echo "export PATH=$PATH:$(go env GOPATH)/bin" >> $HOME/.profile
source ~/.profile
printf "Updated!\n"
go version