#!/bin/bash

if [ $# -lt 2 ] #expecting 2 arguments
  then
    echo "Not enough arguments provided"
    exit 1
  else
    group="${1}"
    username="${1}" #by default we're installing user/group with the same name
    website_url="${2}"
fi

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

sudo ee site create $website_url

echo "->Created $website_url stack"


