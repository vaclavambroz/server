#!/bin/bash

password=$(date +%s | sha256sum | base64 | head -c 22)
database=$1

if [[ ! -z $database ]]; then
  mysql -e "CREATE DATABASE $1 CHARACTER SET utf8 COLLATE utf8_bin;"
  mysql -e "CREATE USER '$1'@'localhost' IDENTIFIED BY '$password';"
  mysql -e "GRANT USAGE on $1.* to $1@localhost identified by '$password';"
  mysql -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';"
  echo "Created database $1 with password $password"
  exit 0
else
  echo "USAGE:"
  echo $0 "database"
  exit 2
fi
