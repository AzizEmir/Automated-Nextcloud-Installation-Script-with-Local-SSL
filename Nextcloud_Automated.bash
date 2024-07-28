#!/usr/bin/env bash

if (( $(id -u) != 0 )); then
    echo "I'm not root"
    exit 1
fi

echo "
   _____ _______       _____ _______            _____ _______   _    _ _____  _____       _______ ______ 
  / ____|__   __|/\   |  __ \__   __|     /\   |  __ \__   __| | |  | |  __ \|  __ \   /\|__   __|  ____|
 | (___    | |  /  \  | |__) | | |       /  \  | |__) | | |    | |  | | |__) | |  | | /  \  | |  | |__   
  \___ \   | | / /\ \ |  _  /  | |      / /\ \ |  ___/  | |    | |  | |  ___/| |  | |/ /\ \ | |  |  __|  
  ____) |  | |/ ____ \| | \ \  | |     / ____ \| |      | |    | |__| | |    | |__| / ____ \| |  | |____ 
 |_____/   |_/_/    \_\_|  \_\ |_|    /_/    \_\_|      |_|     \____/|_|    |_____/_/    \_\_|  |______|
"

apt update


cat <<EOF
  ______ _   _ _____             _____ _______   _    _ _____  _____       _______ ______ 
 |  ____| \ | |  __ \      /\   |  __ \__   __| | |  | |  __ \|  __ \   /\|__   __|  ____|
 | |__  |  \| | |  | |    /  \  | |__) | | |    | |  | | |__) | |  | | /  \  | |  | |__   
 |  __| | . \` | |  | |   / /\ \ |  ___/  | |    | |  | |  ___/| |  | |/ /\ \ | |  |  __|  
 | |____| |\  | |__| |  / ____ \| |      | |    | |__| | |    | |__| / ____ \| |  | |____ 
 |______|_| \_|_____/  /_/    \_\_|      |_|     \____/|_|    |_____/_/    \_\_|  |______|
EOF

cd /root

apt install figlet > /dev/null 2>&1

read -rep "Local Domain name is =" -i "nextcloud.home" answer

LOCAL_DOMAIN_NAME=$answer

read -rep "mariadb root password =" -i "123" answer

MARIADB_ROOT_PASSWORD=$answer

figlet "$LOCAL_DOMAIN_NAME"

apt install -y mkcert

apt install -y apache2 

mkcert --install

mkcert $LOCAL_DOMAIN_NAME

rootCA=/root/.local/share/mkcert/rootCA.pem

figlet "PHP packages"

php_packages=(
    php
    php-curl
    php-cli
    php-mysql
    php-gd
    php-common
    php-xml
    php-json
    php-intl
    php-pear
    php-imagick
    php-dev
    php-common
    php-mbstring
    php-zip
    php-soap
    php-bz2
    php-bcmath
    php-gmp
    php-apcu
    libmagickcore-dev
    php-redis
    php-memcached
)

apt install -y "${php_packages[@]}"

time_zone=$(cat /etc/timezone)

figlet "[opcache]"


sed -i "s|;date.timezone =|date.timezone = $time_zone|" /etc/php/8.2/apache2/php.ini
sed -i 's/^memory_limit = 128M/memory_limit = 512M/' /etc/php/8.2/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 500M/' /etc/php/8.2/apache2/php.ini
sed -i 's/^post_max_size\s*=\s*8M/post_max_size = 600M/' /etc/php/8.2/apache2/php.ini
sed -i 's/^max_execution_time = 30/max_execution_time = 300/' /etc/php/8.2/apache2/php.ini

cat <<EOF
display_errors = Off
output_buffering = Off
EOF


sed -i 's/^; display_errors/display_errors = Off/' /etc/php/8.2/apache2/php.ini

sed -i '/^; output_buffering/s/^; output_buffering/output_buffering = Off/' /etc/php/8.2/apache2/php.ini


cat <<EOF
opcache.enable = 1
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
opcache.memory_consumption = 128
opcache.save_comments = 1
opcache.revalidate_freq = 1
EOF

sed -i 's/^;opcache.enable=1/opcache.enable=1/' /etc/php/8.2/apache2/php.ini

sed -i 's/^;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer = 8/' /etc/php/8.2/apache2/php.ini

sed -i 's/^;opcache.max_accelerated_files=10000/opcache.max_accelerated_files = 10000/' /etc/php/8.2/apache2/php.ini

sed -i 's/^;opcache.memory_consumption=128/opcache.memory_consumption=128/' /etc/php/8.2/apache2/php.ini

sed -i 's/^;opcache.save_comments=1$/opcache.save_comments = 1/' /etc/php/8.2/apache2/php.ini

sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq = 1/' /etc/php/8.2/apache2/php.ini

systemctl restart apache2


echo "
  __  __          _____  _____          _____  ____     _____ ______ _______      ________ _____  
 |  \/  |   /\   |  __ \|_   _|   /\   |  __ \|  _ \   / ____|  ____|  __ \ \    / /  ____|  __ \ 
 | \  / |  /  \  | |__) | | |    /  \  | |  | | |_) | | (___ | |__  | |__) \ \  / /| |__  | |__) |
 | |\/| | / /\ \ |  _  /  | |   / /\ \ | |  | |  _ <   \___ \|  __| |  _  / \ \/ / |  __| |  _  / 
 | |  | |/ ____ \| | \ \ _| |_ / ____ \| |__| | |_) |  ____) | |____| | \ \  \  /  | |____| | \ \ 
 |_|  |_/_/    \_\_|  \_\_____/_/    \_\_____/|____/  |_____/|______|_|  \_\  \/   |______|_|  \_\
"

apt install -y mariadb-server

apt install -y expect

#!/usr/bin/env bash

# Define the new root password and other options
ROOT_PASSWORD=""
NEW_ROOT_PASSWORD=$MARIADB_ROOT_PASSWORD
UNIX_SOCKET="n"
REMOVE_ANONYMOUS_USERS="Y"
DISALLOW_ROOT_LOGIN_REMOTELY="Y"
REMOVE_TEST_DATABASE="Y"
RELOAD_PRIVILEGE_TABLES="Y"

# Use expect to automate mariadb-secure-installation
/usr/bin/expect <<EOF
spawn mariadb-secure-installation

expect "Enter current password for root (enter for none):"
send "$ROOT_PASSWORD\r"

expect "Switch to unix_socket authentication \\\[Y/n\\\]"
send "$UNIX_SOCKET\r"

expect "Change the root password? \\\[Y/n\\\]"
send "Y\r"

expect "New password:"
send "$NEW_ROOT_PASSWORD\r"

expect "Re-enter new password:"
send "$NEW_ROOT_PASSWORD\r"

expect "Remove anonymous users? \\\[Y/n\\\]"
send "$REMOVE_ANONYMOUS_USERS\r"

expect "Disallow root login remotely? \\\[Y/n\\\]"
send "$DISALLOW_ROOT_LOGIN_REMOTELY\r"

expect "Remove test database and access to it? \\\[Y/n\\\]"
send "$REMOVE_TEST_DATABASE\r"

expect "Reload privilege tables now? \\\[Y/n\\\]"
send "$RELOAD_PRIVILEGE_TABLES\r"

expect eof
EOF

# Define database parameters
DB_NAME="nextcloud_db"
DB_USER="nextclouduser"
DB_PASSWORD=$MARIADB_ROOT_PASSWORD

# Connect to MariaDB and execute SQL commands
/usr/bin/expect <<EOF
spawn mysql -u root -p
expect "Enter password:"
send "$NEW_ROOT_PASSWORD\r"
expect "mysql>"
send "CREATE DATABASE $DB_NAME;\r"
expect "mysql>"
send "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';\r"
expect "mysql>"
send "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';\r"
expect "mysql>"
send "FLUSH PRIVILEGES;\r"
expect "mysql>"
send "exit\r"
expect eof
EOF

figlet "NEXTCLOUD"

apt install curl unzip -y
cd /var/www/


figlet "START DOWNLOADING NEXTCLOUD"

curl -o nextcloud.zip https://download.nextcloud.com/server/releases/latest.zip  > /dev/null 2>&1

figlet "END DOWNLOADING NEXTCLOUD"

figlet "START EXTRACT ZIP"

unzip nextcloud.zip > /dev/null 2>&1

figlet "END EXTRACT ZIP"

chown -R www-data:www-data nextcloud

rm -f /etc/apache2/sites-available/*

cat <<'EOF' > /etc/apache2/sites-available/nextcloud.conf.template
<VirtualHost *:80>
    ServerName $LOCAL_DOMAIN_NAME
    DocumentRoot /var/www/nextcloud/

    # log files
    ErrorLog /var/log/apache2/nextcloud-error.log
    CustomLog /var/log/apache2/nextcloud-access.log combined

    <Directory /var/www/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All

        <IfModule mod_dav.c>
            Dav off
        </IfModule>

        SetEnv HOME /var/www/nextcloud
        SetEnv HTTP_HOME /var/www/nextcloud
    </Directory>

    # HTTP'den HTTPS'ye yönlendirme
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>

<VirtualHost *:443>
    ServerName $LOCAL_DOMAIN_NAME
    DocumentRoot /var/www/nextcloud/

    # SSL Sertifikaları
    SSLEngine on
    SSLCertificateFile /root/nextcloud.home.pem
    SSLCertificateKeyFile /root/nextcloud.home-key.pem

    # log files
    ErrorLog /var/log/apache2/nextcloud-error.log
    CustomLog /var/log/apache2/nextcloud-access.log combined

    <Directory /var/www/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All

        <IfModule mod_dav.c>
            Dav off
        </IfModule>

        SetEnv HOME /var/www/nextcloud
        SetEnv HTTP_HOME /var/www/nextcloud

        # SSL/TLS güvenlik ayarları
        SSLOptions +StrictRequire
        <IfModule mod_headers.c>
            Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"
        </IfModule>
    </Directory>
</VirtualHost>
EOF

export LOCAL_DOMAIN_NAME=$LOCAL_DOMAIN_NAME

envsubst '$LOCAL_DOMAIN_NAME' < /etc/apache2/sites-available/nextcloud.conf.template > /etc/apache2/sites-available/nextcloud.conf

a2ensite nextcloud.conf

a2enmod rewrite

a2enmod ssl

systemctl restart apache2

echo "scp root@ip-adress:$rootCA ./"
echo "sudo sed -i '/^# The following lines are desirable for IPv6 capable hosts/i ip-adress    nextcloud.home' /etc/hosts"
echo "DB_NAME=nextcloud_db"
echo "DB_USER=nextclouduser"

apt purge -y figlet > /dev/null 2>&1