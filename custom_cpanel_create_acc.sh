#!/bin/bash

read -p "Enter cPanel username: " CPANEL_USER
read -p "Enter domain name (without 'www'): " DOMAIN_NAME
read -p "Enter database name: " DB_NAME
read -p "Enter database username: " DB_USER


CPANEL_PASS=$(openssl rand -base64 16)

uapi --user=root createacct domain=$DOMAIN_NAME username=$CPANEL_USER password=$CPANEL_PASS plan=Default


DB_PASS=$(openssl rand -base64 16)

uapi --user=$CPANEL_USER Mysql create_database name=$DB_NAME

uapi --user=$CPANEL_USER Mysql create_user name=$DB_USER password=$DB_PASS

uapi --user=$CPANEL_USER Mysql set_privileges_on_database user=$DB_USER database=$DB_NAME privileges=ALL
echo "Account and database created successfully:"
echo "cPanel username: $CPANEL_USER"
echo "cPanel password: $CPANEL_PASS"
echo "Domain name: $DOMAIN_NAME"
echo "Database name: $DB_NAME"
echo "Database username: $DB_USER"
echo "Database password: $DB_PASS"

read -p "Enter destination cPanel username: " DEST_USER

read -p "Are you sure you want to copy the contents of /home/$DEST_USER/ to /home/$CPANEL_USER/ [y/n] " CONFIRMATION





if [ "$CONFIRMATION" == "y" ] || [ "$CONFIRMATION" == "Y" ]
then
  rsync -ahpHP --quiet /home/$DEST_USER/public_html/ /home/$CPANEL_USER/public_html/

  echo "Contents of /home/$DEST_USER/ have been copied to /home/$CPANEL_USER/."
else
  echo "Operation cancelled by user."
fi






