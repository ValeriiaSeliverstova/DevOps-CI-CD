#!/bin/bash
set -e
sudo apt update

# install docker

if ! command -v docker &> /dev/null
then
    echo "Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker already installed"
fi

#install Docker Compose
if ! command -v docker compose &> /dev/null
then
    echo "Installing Docker Compose..."
    sudo apt install -y docker-compose-plugin
else
    echo "Docker Compose already installed"
fi

#install Python
if ! command -v python3 &> /dev/null
then
    echo "Installing Python..."
    sudo apt install -y python3 python3-venv
else
    echo "Python already installed"
fi

# Create venv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

if [ ! -f "venv/bin/activate" ]; then
    echo "ERROR: venv not created!"
    exit 1
fi

# Activate venv
source venv/bin/activate

#install pip
pip install --upgrade pip


#Django setup
if ! pip show django &> /dev/null
then
	echo "Installing Django.."
	pip install django
else
	echo "Django is already installed."
fi

echo "Setup is completed!"
