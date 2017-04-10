#!/bin/bash

#reading config
. config.cfg

if [ $# -lt 2 ] #expecting 2 arguments
  then
    echo "Not enough arguments provided"
    exit 1
  else
    group="${1}"
    username="${1}" #by default we're installing user/group with the same name
    website_url="${2}"
fi

fpm_config=$(<fpm.cfg)

#terminatin if the installation folder already exists
if [ -d "/var/www/${website_url}" ]; then
  echo "Website ${website_url} seems to be already installed mate! Please check again. Terminating install!"
  exit 1
fi


#checking if www folder exists - on new installations it doesn't yet
if [ ! -d "/var/www" ]; then
  mkdir -p /var/www;
fi

#checking if group / user already exists - if yes ask what to do with it
if [ $(getent group $group) ];
  then
    echo "Group ${group} already exists. Would you like to still use the same one (enter 1) or a new one (enter 2)?"
    select yn in "Yes" "No"; do
      case $yn in
        Yes ) break;;
        No ) echo "What is the new group name?";read new_category; group=$new_category; sudo groupadd $group; break;;
      esac
    done
  else
    #let's add a new group then
    sudo groupadd $group
fi

echo "->Added new group ${group}"

#same thing for user - checking if exists if not what to do with it?
if id -u "$username" >/dev/null 2>&1;
  then
    echo "User ${username} already exists. Would you like to still use the same one (enter 1) or a new one (enter 2)?"
    select yn in "Yes" "No"; do
      case $yn in
        Yes ) break;;
        No ) echo "What is the new username?";read new_username; username=$new_username; sudo useradd -s /bin/false -d /var/www/$website_url -m -g $group $username; break;;
      esac
    done
  else
    #let's add a new user then
    sudo useradd -s /bin/false -d /var/www/$website_url -m -g $group $username
fi

echo "->Added new user ${username}"
#creating the website config itself based on EasyEngine
sudo ee site create $website_url

echo "->Created $website_url stack"
echo "->Creating new nginx conf"

#replacing placeholders from fpm config with our variables
fpm_config="${fpm_config//GROUPNAME/$group}"
fpm_config="${fpm_config//USERNAME/$username}"

#saving fpm socket config
echo "$fpm_config" | sudo tee ${php_path}/${group}.conf > /dev/null

echo "->Created fpm config"

#adding our newly created socket to website nginx settings
site_extra="\n\nlocation ~ \.php$ { \\
     include /etc/nginx/fastcgi_params; \\
     fastcgi_pass unix:/var/run/php/php5.6-fpm-$group.sock; \\
     fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name; \\
}"

wp_config="include common/wpfc.conf; \\
include common/wpcommon.conf;"

sudo sed -i "s|^\s*root.*|& $site_extra|" /etc/nginx/sites-available/$website_url
sudo sed -i "s|^\s*include common.*|$wp_config\n&|" /etc/nginx/sites-available/$website_url

sudo service php5.6-fpm restart #change it to something more universal
sudo service nginx restart

echo "->Modified nginx settings, added socket to website config"

#creating S3 bucket
#aws s3 mb s3://fl-$(group)-media/

#aws iam create-user --user-name $(group)-media

