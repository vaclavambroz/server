#!/bin/bash

domain=$1
user=$2

if [[ ! -z $domain && ! -z $user ]]; then
  #remove virtualhost, data and logs
  rm -rf /etc/apache2/sites-available/$1.conf
  rm -rf /etc/apache2/sites-enabled/$1.conf
  rm -rf /var/www/html/$1
  rm -rf /var/www/logs/$1

  #remove pool
  rm -rf /etc/php/*/fpm/pool.d/$1.conf

  #remove records from /etc/hosts
  sed -i -e "/$1/d" /etc/hosts

  #stop service to delete user
  service apache2 stop && systemctl stop php8.2-fpm

  #delete user
  userdel $2

  #start services
  service apache2 restart && systemctl restart php8.2-fpm
  exit 0

else
  ls -la /var/www/html/
  echo ""
  echo "USAGE:"
  echo $0 "domain" "user"
  echo "EXAMPLE: $0" "domain.tld" "domain_tld"
  exit 2
fi
