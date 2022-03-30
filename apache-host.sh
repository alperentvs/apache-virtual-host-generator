#! /bin/bash

OSname="null"

if [[ -f /etc/os-release ]]
then
	if grep -q Ubuntu /etc/os-release
	then
		echo "Our distro is Ubuntu"
		OSname="Ubuntu"
	fi
else
	echo "Can't find /etc/os-release file. Terminating."
	exit
fi

if [[ ${OSname}=="Ubuntu" ]]
then
	if [[ ! -f /usr/sbin/apache2 ]] 
	then
		echo "Seems like Apache is not installed. Terminating."
		exit
	fi

	if [[ ! -d /etc/apache2/sites-enabled ]]
	then
		mkdir /etc/apache2/sites-enabled && echo "/etc/apache2/sites-enabled directory created."
		chmod 755 /etc/apache2/sites-enabled
	fi
	if [[ ! -d /etc/apache2/sites-available ]]
	then
		mkdir /etc/apache2/sites-available && echo "/etc/apache2/sites-available directory created."
		chmod 755 /etc/apache2/sites-available
	fi
fi