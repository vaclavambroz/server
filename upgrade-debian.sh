#!/bin/bash

#variables
hostname="$(hostname)"
kernel="$(uname -r)"
os="$(cat /etc/os-release | grep NAME | grep -v PRETTY | grep -v VERSION | grep -v UBUNTU_CODENAME | sed -e 's/NAME=//g' | sed -e 's/"//g')"

#title
clear
echo Operating system: "${os}"
echo Hostname: "${hostname}"
echo Kernel: "${kernel}"
echo ""

#update
echo "########## Updating repositories ##########"
apt update
echo ""

#upgrade packages
echo "######### Upgrading all packages ##########"
apt upgrade -y
echo ""

#cleaning
echo "######### Deleting cache and old packages ##########"
apt clean
apt autoremove -y
echo ""

#modules
if dpkg -l | grep "module-assistant" 2>/dev/null | grep -q "ii"; then
  :
else
  echo "######### Installing module-assistant package ##########"
  apt install -y module-assistant
  echo ""
fi

echo "######### Upgrading modules ##########"
m-a update
m-a prepare <<EOF
y
EOF
echo ""
