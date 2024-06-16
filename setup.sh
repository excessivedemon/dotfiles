#!/bin/bash

# Check for Homebrew and install if not found
if ! command -v brew &> /dev/null
then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Ensure brew is up-to-date
brew update

# Install Ansible
if ! command -v ansible &> /dev/null
then
    echo "Ansible is not installed. Installing Ansible..."
    brew install ansible
else
    echo "Ansible is already installed."
fi

# Run the Ansible playbooks
ansible-playbook common_dependencies.yml
ansible-playbook programming_languages.yml
ansible-playbook setup_vim.yml
