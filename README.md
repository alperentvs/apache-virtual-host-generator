# Apache Virtual Host Generator
**Apache Virtual Host Generator** is a tool that simplifies the process of defining a virtual host on an Apache Web Server.
## Preconditions
* This script currently supports Ubuntu and CentOS distros.
* You must run this script as super user.
* This script supports Apache Web Server only.
## Usage
* Simply, run the script with `./apache-host.sh` and follow the instructions.
* To delete a virtual host configuration, use "--delete" option.
    - E.g.
        ```bash
        ./apache-host.sh --delete alperen.local
        ```
## Features
* Script creates "html" and "log" directories for your web site under `/var/www` directory.
* Then creates a virtual host configuration under proper directories and restarts your Apache.
* Lastly, creates a DNS record with 127.0.0.1 under `/etc/hosts` if desired.
* You may choose to enable your new configuration later.