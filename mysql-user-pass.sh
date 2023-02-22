#!/bin/bash

user=$1
password=$(date +%s | sha256sum | base64 | head -c 22)

if [[ ! -z $user ]]; then
  mysql -e "set password for $user@'localhost' = PASSWORD('$password');"
  mysql -e "grant usage on $user.* to $user@localhost identified by '$password';"
  mysql -e "grant all privileges on $user.* to $user@localhost ;"
  echo "Password for user $user changed to $password"
  exit 0
else
  echo "USAGE:"
  echo $0 "user"
  exit 2
fi
