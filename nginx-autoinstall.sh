#!/bin/bash

# Colors
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"

# Check root access
if [[ "$EUID" -ne 0 ]]; then
	echo -e "${CRED}SMerci de vous connecter en root${CEND}"
	exit 1
fi



# Clear log file

clear
echo ""
echo "Bienvenue dans l'installation de Nginx et modules complémentaires"
echo ""
echo "Que souhaitez vous faire ? ?"
echo "   1) Installer NGINX+PHP7.2"
echo "   2) "
echo "   3) Installed NGINX+PHP7.2+ADMINER"
echo "   4) Exit"
echo ""
while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" ]]; do
	read -p "Merci de selectionner une option [1-4]: " OPTION
done
case $OPTION in
	1)
		echo ""
		echo "Le script va installer nginx tout simplement sur le port de votre choix"
		echo ""
		echo "Sur quel port souhaitez vous l'installer ?"
		echo "   1) 7979"
		echo "   2) 80"
		echo "   3) 8080"
		echo ""
		
		read -p "Entrer le port de votre choix : " NGINX_PORT
		read -p "Entrer le dossier de destination (/var/www/DOSSIER) " NGINX_DIRECTORY
	
		
		echo ""
		echo "Quel nom de fichier souhaitez vous dans votre configuration site enable ?"
		read -r fichierinstall
		echo "Installation en cours"

		echo "Mise à jours"
		apt-get update && apt-get upgrade -y

		echo "Installation de NGINX et MariaDB"
		apt-get install nginx -y
		apt-get install apt-transport-https lsb-release ca-certificates -y
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
		apt-get update
		apt-get install php7.2 -y
		apt-get install php7.2-fpm -y
		apt-get install php7.2-mysql -y
		apt-get install mariadb-server -y


		echo "Configuration de NGINX"
		cd /etc/nginx/sites-enabled
		rm default
		cd /etc/nginx/sites-available
		rm default
		wget https://raw.githubusercontent.com/Whisper40/script-nginx-et-autre/nginx.conf -P /etc/nginx/sites-available/
		mv nginx.conf $fichierinstall


		

		sed -i "s|@NGINX_PORT@|$NGINX_PORT|g;" /etc/nginx/sites-available/$fichierinstall
		sed -i "s|@NGINX_DIRECTORY@|$NGINX_DIRECTORY|g;" /etc/nginx/sites-available/$fichierinstall

		echo ""
		echo "Mise en place en enable"
		ln -s /etc/nginx/sites-available/$fichierinstall /etc/nginx/sites-enabled/$fichierinstall

		cd /var/www
		mkdir $NGINX_DIRECTORY
		cd $NGINX_DIRECTORY
		cat >> index.php << _NTPconf_

		<?php
		phpinfo();
		?>

_NTPconf_
		service nginx restart
		service php7.2-fpm restart

			echo "Voulez vous lancer mysql_secure_installation ? Y/N"
			read -r REPSQL

		
		
		if [ "$REPSQL" = "Y" ]; then
				mysql_secure_installation
				
		else
			echo "L'installation sécurisée n'a pas été exéctuée ! "
		fi	

		echo "Mot de passe sql ?"		
		read -r MDPSQL


		mysql -u root -p<<MYSQL_NGINX

		GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MDPSQL' WITH GRANT OPTION;
		FLUSH PRIVILEGES;
MYSQL_NGINX

	exit



		
	;;
	2) # Uninstall Nginx
		
		echo "TEST"
	

	exit
	;;
	3) # Update the script
		
		exit
	;;
	4) # Exit
		exit
	;;

esac