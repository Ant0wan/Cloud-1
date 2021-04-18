#!/bin/bash
if cat /etc/crontab | grep "@reboot		root	swapoff -a"; then
	exit 0
fi
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab
printf '$-0i\n@reboot\t\troot\tswapoff -a\n.\nw\n' | ex -s /etc/crontab
