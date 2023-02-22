#!/bin/bash

database=$1

if [[ ! -z $database ]]; then
  mysql -e "DROP DATABASE $1;"
  mysql -e "DROP USER '$1'@'localhost';"
  exit 0
else
  mysql -e "show databases";
  echo "";
  echo "USAGE:"
  echo $0 "database"
  mysql -e "select User from mysql.user;"
  exit 2
fi
