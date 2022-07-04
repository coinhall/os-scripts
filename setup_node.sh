#!/bin/bash
# Installs and configures node.

set -e

node_version=14

# 1) install and configure nvm
printf "\n[Installing nvm]\n\n"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.nvm/nvm.sh
source ~/.bashrc

# 2) install and use node v14
printf "\n[Installing node v$node_version]\n\n"
nvm install $node_version

# 3) install yarn
printf "\n[Installing yarn globally]\n\n"
npm i -g yarn

echo # for new line
echo "The following are installed:"
echo "nvm $(nvm --version)"
echo "node $(node --version)"
echo "yarn $(yarn --version)"
