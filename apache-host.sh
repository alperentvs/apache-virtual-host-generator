#! /bin/bash

OSname="null"
mainconf="/etc/apache2/apache2.conf"

#Root control:
if [[ $(id -u) -ne 0 ]]
then
	echo "You must run this script as super user."
	exit
fi

#Check whether os-release file exist:
if [[ -f /etc/os-release ]]
then
    #Check whether distro is Ubuntu:
    if grep -q Ubuntu /etc/os-release
    then
        echo "Our distro is Ubuntu"
        OSname="Ubuntu"
        apache_bin="/usr/sbin/apache2"
        sites_enabled="/etc/apache2/sites-enabled"
        sites_available="/etc/apache2/sites-available"
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
    if [[ ! -f ${apache_bin} ]]
    then
        echo "Seems like Apache is not installed. Terminating."
        exit
    fi
    
    #Check for sites-enabled and sites-available directories:
    if [[ ! -d ${sites_enabled} ]]
    then
        #Create directory with proper permissions:
        mkdir ${sites_enabled} && echo "${sites_enabled} directory created."
        chmod 755 ${sites_enabled}
    fi

    if [[ ! -d ${sites_available} ]]
    then
        #Create directory with proper permissions:
        mkdir ${sites_available} && echo "${sites_available} directory created."
        chmod 755 ${sites_available}
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
    
    #Get URL from user:
    printf "Enter your URL: "
    read url
    #Get alias from user:
    printf "(Optional) Enter server alias [${url}]: "
    read alias
    #If alias is empty, use URL instead:
    if [[ -z ${alias} ]]
    then
        alias=${url}
    fi

    #Check whether web site directory is exists:
    if [[ -d /var/www/${url} ]]
    then
        echo "Web site ${url} is already exists under /var/www/${url}. Terminating."
        exit
    else
        #Create html and log directories for new web site:
        mkdir -p /var/www/${url}/html
        echo "Web site directory created: /var/www/${url}/html"
        mkdir -p /var/www/${url}/log
        echo "Log directory created: /var/www/${url}/log"
    fi
    
    #Check whether a virtual host configuration already exists for new web site:
    if [[ -f ${sites_available}/${url}.conf ]]
    then
        #There's a configuration. Don't overwrite it. Exit:
        echo "A virtual host configuration file already exists at ${sites_available}/${url}.conf"
        echo "Terminating."
        exit
    else
        #Create new virtual host configuration file:
        echo "Generating virtual host configuration file..."
        cat << EOF > ${sites_available}/${url}.conf
<VirtualHost *:80>
    ServerName ${url}
    ServerAlias ${alias}
    DocumentRoot /var/www/${url}/html
    ErrorLog /var/www/${url}/log/error.log
    CustomLog /var/www/${url}/log/access.log combined
</VirtualHost>
EOF
        echo "Virtual host configuration generated at ${sites_available}/${url}.conf"

        #Enable new web site or not:
        printf "Do you want to enable your new web site (${url}) [y/n]: "
        read enableanswer
        #Enable web site with symbolic link:
        if [[ ${enableanswer} == "y" ]]
        then
            ln -s ${sites_available}/${url}.conf ${sites_enabled}/${url}.conf 2> /dev/null
            #Check whether link created:
            if [[ $? -eq 0 ]]
            then
                echo "Web site enabled."
                echo "Restarting Apache..."
                systemctl restart apache2 2> /dev/null
                #Check if Apache restarted:
                if [[ $? -eq 0 ]]
                then
                    echo "Apache restarted successfully. You can now access your web site ${url}"
                    echo "Bye!"
                else
                    echo "Could not restart Apache. You may want to check 'journalctl -xe' for further information."
                fi
            else
                echo "Could not enable web site. Maybe ${sites_enabled}/${url}.conf link already exists?"
            fi
        else
            echo "You have to link ${sites_available}/${url}.conf under ${sites_enabled} directory to enable your virtual host."
            echo ""
            echo "You can use this command:"
            echo "ln -s ${sites_available}/${url}.conf ${sites_enabled}/${url}.conf"
            echo ""
            echo "Don't forget to restart Apache service."
        fi #End enabling virtual host
    fi #End virtual host configuration
fi #End Ubuntu
