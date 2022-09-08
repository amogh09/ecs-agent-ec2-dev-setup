#!/bin/bash

set -e

sudo yum update

# Zsh
sudo yum -y install zsh 

# Linux util
sudo yum -y install util-linux-user

# Set zsh as default
sudo chsh -s "$(which zsh)"

# oh my zsh
if [[ -z "${ZSH}" ]]; then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install some tools
sudo yum -y install gcc git aws-cli wget

# Install neovim
if ! command -v nvim &> /dev/null; then
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	./nvim.appimage || echo "Letting this pass"
	./nvim.appimage --appimage-extract || echo "Letting this pass"
	./squashfs-root/AppRun --version
	sudo mv squashfs-root /
	sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
fi

# Set up neovim
if [ ! -d ~/.config/nvim ]; then
	mkdir -p ~/.config
	git clone https://github.com/amogh09/nvim-config-lite.git ~/.config/nvim
	git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.config/nvim/pack/packer/start/packer.nvim
fi

# Install go
if [ ! -d /usr/local/go ]; then
	echo "Go does not exist. Installing it."
	GOVERSION="1.18.3"
	GOLANG_TAR="go${GOVERSION}.linux-amd64.tar.gz"
	wget -O /tmp/${GOLANG_TAR} https://storage.googleapis.com/golang/${GOLANG_TAR}
	sudo tar -C /usr/local -xzf /tmp/${GOLANG_TAR}
	echo export PATH=$PATH:/usr/local/go/bin >> ~/.zshrc
	echo export GOPATH=~/go >> ~/.zshrc

	# Install gopls
	go install golang.org/x/tools/gopls@latest
fi

# Docker setup
if [ -z $(getent group docker) ]; then
	sudo groupadd docker           # Add docker group
	sudo gpasswd -a ${USER} docker # Add current user into the group
	sudo service docker restart    # Restart the docker service
fi

# Create Agent working directory 
AGENT_DIR=~/go/src/github.com/aws/amazon-ecs-agent
if [ ! -d $AGENT_DIR ]; then
	mkdir -p ~/go/src/github.com/aws 
	cd ~/go/src/github.com/aws/

	# Clone ECS Agent project 
	git clone https://github.com/amogh09/amazon-ecs-agent.git
fi

# Install neovim remote
pip3 install neovim-remote

# Install jq
sudo yum -y install jq
