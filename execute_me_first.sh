#!/usr/bin/env bash
# Detect package type
_package_manager_detect() {
	command -v apt &>/dev/null && pk="apt" && return
	command -v yum &>/dev/null && pk="yum" && return
	_error "No supported package manager installed on system"
	_error "(supported: apt or yum)"
	exit 1
}
_package_manager_detect

# Install Ansible
sudo ${pk} update
sudo ${pk} install ansible

# Install Ansible modules
ansible-galaxy collection install -r requirements.yaml

# Readme help
tput init; tput setaf 41; echo "Add ansible env variable for no host key checking:"
tput setaf 250; echo "  \`export ANSIBLE_HOST_KEY_CHECKING=False\`"; echo
tput setaf 41; echo "Set DB and Wordpress password:"
tput setaf 250; echo "  \`export MYSQL_ROOT_PASSWORD=plussimple; export MYSQL_USER=wordpress; export MYSQL_PASSWORD=password; export MYSQL_DATABASE=wordpress\`"; echo
tput setaf 41; echo "Execute Ansible playbook:"
tput setaf 250; echo "  \`ansible-playbook -i hosts cloud-1.yaml\`"
