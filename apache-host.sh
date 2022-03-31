#! /bin/bash

OSname="null"
mainconf="/etc/apache2/apache2.conf"

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

	if [[ ! -f ${mainconf} ]]
	then
		echo "Can't find Apache configuration file. Terminating."
		exit
	elif ! grep -Fq 'IncludeOptional sites-enabled/*.conf' ${mainconf}
	then
		echo "IncludeOptional sites-enabled/*.conf" >> ${mainconf}
		echo "Enabled Virtual Host includes in ${mainconf}"
	else
		echo "Virtual Host is already enabled in ${mainconf}"
	fi
fi