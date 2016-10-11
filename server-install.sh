#!/bin/bash 
echo "Ubuntu Server 16.04 installation script for..."
echo "- Nginx"
echo "- Php7.0"
echo "- MariaDB"
echo "- Git, Curl & Composer"
echo "- Node.JS, Gulp, Bower & Socket.io"
read -p "Continue with installation? (y/n)" CONTINUE
if [ $CONTINUE = "y" ]; then
	echo "Note: Script assumes you have a file named nginx-site in script directory to be copied to /etc/nginx/sites-available"
	read -p "Install Nginx? (y/n)" NGINX
	if [ $NGINX = "y" ]; then
		sudo apt-get install -y nginx
		sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
		echo "Moving default site file to /etc/nginx/sites-available/default.backup"
		sudo cp nginx-site /etc/nginx/sites-available/myapp
		read -p "Would you like to modify the Nginx site file? (y/n)" MOD
		if [ $MOD = "y" ]; then
			sudo nano /etc/nginx/sites-available/myapp
		fi
		sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp
		sudo nginx -t
		sudo systemctl reload nginx
		sudo systemctl restart nginx
		read -p "Install OpenSSL & Generate SSL Cert for Nginx? (y/n)" SSL
		if [ $SSL = "y" ]; then
			sudo apt-get install -y openssl
			sudo mkdir /etc/nginx/ssl
			sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
			sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
			sudo systemctl restart nginx.service
		fi
	fi	
	read -p "Install PHP7.0? (y/n)" PHP
	if [ $PHP = "y" ]; then
		sudo apt install -y php7.0 php7.0-fpm php7.0-cli php7.0-mcrypt php7.0-mbstring php7.0-mysql
		sudo echo 'cgi.fix_pathinfo=0' >> /etc/php/7.0/fpm/php.ini
		echo 'Adding cgi.fix_pathinfo=0 to /etc/php/7.0/fpm/php.ini'
		read -p "Would you like to modify the FPM php.ini file? (y/n)" INI
		if [ $INI = "y" ]; then
			sudo nano /etc/php/7.0/fpm/php.ini
		fi
		sudo systemctl restart php7.0-fpm
	fi
	read -p "Install MariaDB? (y/n)" MARIADB
	if [ $MARIADB = "y" ]; then
		sudo apt install -y mariadb-server mariadb-client
		sudo mysql_secure_installation
		sudo mysql << EOF
		use mysql;
		update user set plugin=’‘ where User=’root’;
		flush privileges;
		exit
EOF
	fi
	read -p "Install Curl, Git & Composer? (y/n)" CGC
	if [ $CGC = "y" ]; then
		sudo apt-get install -y curl git
		curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
	fi
	read -p "Install Node.js? (y/n)" NODE
	if [ $NODE = "y" ]; then
		echo "Please select a version of Node.js:"
		echo "1. Node.js v 4.x LTS"
		echo "2. Node.js v 6.x"
		read -p "Which version would you like? (1/2)" NODEV
		if [ $NODEV = "1" ]; then
			curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
		else
			curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
		fi
		sudo apt-get install -y nodejs 
		read -p "Install Socket.io, bower & gulp? (y/n)" SIO
		if [ $SIO = "y" ];then
			sudo npm install -g socket.io
			sudo npm install -g bower
			sudo npm install -g gulp-cli
		fi
		
	fi
else
	exit
fi
