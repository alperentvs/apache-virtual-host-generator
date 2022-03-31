#! /bin/bash

OSname="null"
mainconf="/etc/apache2/apache2.conf"

#Check whether os-release file exist:
if [[ -f /etc/os-release ]]
then
	#Check whether distro is Ubuntu:
	if grep -q Ubuntu /etc/os-release
	then
		echo "Our distro is Ubuntu"
		OSname="Ubuntu"
	fi
	#TODO CentOS will be added
else
	echo "Can't find /etc/os-release file. Terminating."
	exit
fi

#Virtual host configuration steps for Ubuntu:
if [[ ${OSname}=="Ubuntu" ]]
then
	#Check whether apache2 binary is exist:
	if [[ ! -f /usr/sbin/apache2 ]] 
	then
		echo "Seems like Apache is not installed. Terminating."
		exit
	fi

	#Check for sites-enabled and sites-available directories:
	if [[ ! -d /etc/apache2/sites-enabled ]]
	then
		#Create directory with proper permissions:
		mkdir /etc/apache2/sites-enabled && echo "/etc/apache2/sites-enabled directory created."
		chmod 755 /etc/apache2/sites-enabled
	fi
	if [[ ! -d /etc/apache2/sites-available ]]
	then
		#Create directory with proper permissions:
		mkdir /etc/apache2/sites-available && echo "/etc/apache2/sites-available directory created."
		chmod 755 /etc/apache2/sites-available
	fi

	#Check whether Apache configuration is exist:
	if [[ ! -f ${mainconf} ]]
	then
		echo "Can't find Apache configuration file. Terminating."
		exit
	#Check whether sites-enabled include is exist:
	elif ! grep -Fq 'IncludeOptional sites-enabled/*.conf' ${mainconf}
	then
		#sites-enabled inclusion:
		echo "IncludeOptional sites-enabled/*.conf" >> ${mainconf}
		echo "Enabled Virtual Host includes in ${mainconf}"
	else
		echo "Virtual Host is already enabled in ${mainconf}"
	fi
fi