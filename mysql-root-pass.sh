#!/bin/bash

pass=$1

if [[ ! -z $pass ]]; then
  mysql -e "set password for root@'localhost' = PASSWORD('$pass');"
  echo "[mysql]" >/etc/mysql/conf.d/mysql.cnf
  echo "user=root" >>/etc/mysql/conf.d/mysql.cnf
  echo "password=$pass" >>/etc/mysql/conf.d/mysql.cnf
  echo "" >>/etc/mysql/conf.d/mysql.cnf
  echo "[mysqldump]" >>/etc/mysql/conf.d/mysql.cnf
  echo "user=root" >>/etc/mysql/conf.d/mysql.cnf
  echo "password=$pass" >>/etc/mysql/conf.d/mysql.cnf
  echo "" >>/etc/mysql/conf.d/mysql.cnf
  echo "[mysqladmin]" >>/etc/mysql/conf.d/mysql.cnf
  echo "user=root" >>/etc/mysql/conf.d/mysql.cnf
  echo "password=$pass" >>/etc/mysql/conf.d/mysql.cnf
  mysql -e "grant usage on root.* to root@localhost identified by '$pass';"
  mysql -e "grant all privileges on *.* to root@localhost ;"
  exit 0
else
  echo "USAGE:"
  echo $0 "password"
  exit 2
fi
