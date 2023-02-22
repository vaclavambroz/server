#!/bin/bash

ip=$1
email=$2
domain=$3
username=$4
php=$5

if [[ ! -z $ip && ! -z $email && ! -z $domain && ! -z $username && ! -z $php ]]; then

#user
useradd -m -d /var/www/html/$domain $username

#pool for php version
tee "/etc/php/8.2/fpm/pool.d/$domain.conf" > /dev/null <<EOF
[$domain]

user = $username
group = $username

listen = /run/php/8.2-fpm_$domain.sock
listen.owner = $username
listen.group = $username
listen.mode = 0666

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 5
pm.max_requests = 0

php_admin_value[open_basedir] = /var/www/html/$domain:/tmp:/dev/random:/dev/urandom
EOF

#virtualhost
tee "/etc/apache2/sites-available/$domain.conf" > /dev/null <<EOF
<VirtualHost $ip:80>

#### DOMAIN - BEGIN ####
ServerName $domain
#### DOMAIN - END ####

#### SUEXEC - BEGIN ####
SuexecUserGroup "$username" "$username"
#### SUEXEC - END ####

#### ADMIN - BEGIN ####
ServerAdmin $email
#### ADMIN - END ####

#### DIRECTORY - BEGIN ####
DocumentRoot /var/www/html/$domain/
#### DIRECTORY - END ####

#### DIRECTORY SETTINGS - BEGIN ####
<Directory /var/www/html/$domain/>
Options +FollowSymlinks
Options +Indexes
AllowOverride fileinfo indexes limit AuthConfig options=indexes,followsymlinks,multiviews
Require all granted
</Directory>
#### DIRECTORY SETTINGS - END ####

#### FPM SETTINGS - BEGIN ####
<IfModule mod_fcgid.c>
Options +ExecCGI
FcgidConnectTimeout 20
AddType  application/x-httpd-php .php
AddHandler application/x-httpd-php .php
<FilesMatch ".+.ph(ar|p|tml)$">
SetHandler "proxy:unix:/run/php/$php-fpm_$domain.sock|fcgi://localhost"
</FilesMatch>
</IfModule>
#### FPM SETTINGS - END ####

#### LOGS - BEGIN ####
ErrorLog /var/www/logs/$domain/error.log
CustomLog /var/www/logs/$domain/access.log combined
CustomLog ${APACHE_LOG_DIR}/access.log vhost_combined
#LogLevel debug
#### LOGS - END ####

#### SERVER INFO - BEGIN ####
ServerSignature Off
#### SERVER INFO - END ####

#### GZIP COMPRESSION - BEGIN ####
<IfModule mod_deflate.c>
AddOutputFilterByType DEFLATE text/plain
AddOutputFilterByType DEFLATE text/html
AddOutputFilterByType DEFLATE text/xml
AddOutputFilterByType DEFLATE text/css
AddOutputFilterByType DEFLATE application/xml
AddOutputFilterByType DEFLATE application/xhtml+xml
AddOutputFilterByType DEFLATE application/rss+xml
AddOutputFilterByType DEFLATE application/javascript
AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>
#### GZIP COMPRESSION - END ####

</VirtualHost>
EOF

#index file
tee "/var/www/html/$domain/index.php" > /dev/null <<EOF
<?php
phpinfo();
EOF

#file permissons
chown -R $username:$username /var/www/html/$domain/
chmod 644 /var/www/html/$domain/index.php

#turn on
a2ensite $domain
apachectl -t && apachectl graceful

#hosts
echo "127.0.0.1	$domain" >> /etc/hosts

#restart services
systemctl restart apache2  && systemctl restart php8.2-fpm
exit 0

else
  echo "USAGE:"
  echo "$0" "ip" "email" "domain" "username" "php"
  echo "EXAMPLE: $0" "localhost" "vaclav@ambroz.email" "domain.tld" "domain_tld" "8.2"
  exit 2
fi
