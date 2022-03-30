#! /bin/bash

if [[ -f /etc/os-release ]]
then
	if grep -q Ubuntu /etc/os-release
	then
		echo "Our distro is Ubuntu"
	fi
else
	echo "Can't find /etc/os-release file. Terminating."
	exit
fi
