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
sudo ${pk} update
sudo ${pk} install ansible
ansible-galaxy collection install -r requirements.yaml
echo "run \`export ANSIBLE_HOST_KEY_CHECKING=False\`"
echo "then \`ansible-playbook -i hosts wordpress.yaml\`"
