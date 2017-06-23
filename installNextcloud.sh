#!/bin/bash -
#
# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Curt, Sebastien <sebastien.curt@tetras-libre.fr>
#
# This program is free software: you can redistribute it and/or modify # it
# under the terms of the GNU General Public License as published by # the Free
# Software Foundation, either version 3 of the License, or # (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, # but WITHOUT
# ANY WARRANTY; without even the implied warranty of # MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the # GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License # along
# with this program.  If not, see <http://www.gnu.org/licenses/>.

set -o nounset                              # Treat unset variables as an error

###########################################################################
# 1. Download Nexcloud Package
# 2. Check package integrity and source authenticity
# 3.
# 4. Start mysql service
###########################################################################
SCRIPT_DIRECTORY=`pwd`
. `pwd`/installNextcloud.env

RUNNING_DATE_TIME="`date +%Y%m%d%H%M%S`"


if [ ! -d $NEXTCLOUD_DIRECTORY_SOURCES ]
then
    mkdir -p $NEXTCLOUD_DIRECTORY_SOURCES
fi

cd $NEXTCLOUD_DIRECTORY_SOURCES
# 1. Download Nexcloud Package
DEBIAN_FRONTEND='noninteractive' apt-get update \
    && DEBIAN_FRONTEND='noninteractive' apt-get -qq install \
    apg \
    bzip2 \
    gnupg2 \
    isomd5sum \
    php \
    php-apcu \
    php-curl \
    php-gd \
    php-intl \
    php-mcrypt \
    php-mysql \
    sudo \
    tar \
    ufw \
    ${WEB_SERVER_PACKAGES} \
    wget

if [ -d ${NEXTCLOUD_INSTALL_DIR} ]
then
    echo "Nextcloud install directory already exists : " \
        ${NEXTCLOUD_INSTALL_DIR} >&2
    return
fi

echo "Begin to download nextcloud packages"
{
    # insert nextcloud download
    echo "${NEXTCLOUD_PACKAGE}"

    # insert nextcloud release package MD5
    echo "${NEXTCLOUD_PACKAGE}.md5"

    # insert nextcloud GPG release package key
    echo "${NEXTCLOUD_PACKAGE}.asc"
} > $NEXTCLOUD_WGET_INPUT

# Download nextcloud package
wget --output-file=wget_nextcloud.log \
    --base=https://download.nextcloud.com/server/releases/ \
    --tries=5 \
    --continue \
    --timestamping \
    --input-file=$NEXTCLOUD_WGET_INPUT

# Downloa NextCloud GPG
echo "Download authentic key of nextcloud"
wget --output-file=wget_nextcloud.log \
    --tries=5 \
    --continue \
    --timestamping \
    https://nextcloud.com/nextcloud.asc

gpg2 --import nextcloud.asc

echo "Check both package integrity and sources authenticity"
# 2. Check package integrity and source authenticity
md5sum --quiet -c ${NEXTCLOUD_PACKAGE}.md5 < ${NEXTCLOUD_PACKAGE} \
    && LC_ALL="en_US.utf-8" gpg2 --verbose --batch --output - \
    --no-auto-check-trustdb --verify ${NEXTCLOUD_PACKAGE}.asc \
    ${NEXTCLOUD_PACKAGE} 2>&1 | grep -q "Good signature"

# stop if the package isn't reliable
if [ $? -ne 0 ]
then
    echo "Nextcloud packages unsafe" >&2
    return
fi

echo "Extract nextcloud archives"
bzip2 -d ${NEXTCLOUD_PACKAGE}
tar xf ${NEXTCLOUD_VERSION}.tar
cp -r nextcloud $(dirname ${NEXTCLOUD_INSTALL_DIR%/})
chown -R www-data:www-data ${NEXTCLOUD_INSTALL_DIR}
mkdir -p ${NEXTCLOUD_DATA_DIR}
chown -R www-data:www-data ${NEXTCLOUD_DATA_DIR}

echo "Check Nextcloud is not installed"
LC_ALL="en_US.utf-8" sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ -V | grep -q "Nextcloud is not installed"

if [ $? -ne 0 ]
then
    echo "Nextcloud already installed"
    return
fi
echo "Nexcloud isn't already installed => continue installation"

# Set the max php size from 13Mo to 16Go
sed -i.bak -e 's/\(upload_max_filesize\).*/\1 16G/' \
    -e 's/\(post_max_size\).*/\1 16G/' \
    ${NEXTCLOUD_INSTALL_DIR}.htaccess

for dir in apache2 cli fpm
do
    if [ -e /etc/php/7.0/$dir/php.ini ]
    then
        # set max input time from 1 minute to 1 hour
        # php timeout for large file
        sed -i.bak -e 's/\(max_input_time =\).*/\1 3600/' \
            -e 's/\(max_execution_time =\).*/\1 3600/' \
            /etc/php/7.0/$dir/php.ini
    fi
done

echo "configure mysqld compatiblity to nextcloud"
# configure mysqld for nextcloud
{
    echo "[mysqld]"
    echo "binlog-format=MIXED"
    echo "transaction-isolation=READ-COMMITTED"
    echo "innodb_large_prefix=true"
    echo "innodb_file_format=barracuda"
    echo "innodb_file_per_table=true"
} > /etc/mysql/conf.d/mysqld.cnf
echo "mysql configure to nextcloud compatibility : check" \
     "file /etc/mysql/conf.d/mysql.cnf"

# Create nextcloud database in mysql
echo "create nextcloud database"
echo "mysql -e 'CREATE DATABASE nextcloud CHARACTER SET = \"utf8mb4\"" \
     "COLLATE = \"utf8mb4_general_ci\";'"
mysql -e 'CREATE DATABASE nextcloud CHARACTER
SET = "utf8mb4" COLLATE = "utf8mb4_general_ci";'
echo "Nextcloud database created"

nextcloudPassword=${NEXTCLOUD_DATABASE_PASS:-"$(apg -q -a 0 -n 1 -m 21 -M NCL)"}

echo "Create admin Password for nextcloud"
adminPassword=${NEXTCLOUD_ADMIN_PASS=-"$(apg -q -a 0 -n 1 -m 21 -M NCL)"}
{
    echo "[nextcloud]"
    echo "user=admin"
    echo "password=${adminPassword}"
} >> ${HOME}/.passwords
chmod 600 ${HOME}/.passwords
echo "amdin user password store in ${HOME}/.passwords only" \
    "readable by the root user"

echo "Set nextcloud user for nextcloud@localhost in database"
mysql -e "CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY
'${nextcloudPassword}';"
if [ $? -eq 0 ]
then
    echo "nextcloud user set for nextcloud@localhost in database"
else
    echo "error processing : $?" >&2
fi

echo "Grant all privileges to nexcloud user to nextcloud database"
mysql -e "GRANT ALL PRIVILEGES on nextcloud.* to
'nextcloud'@'localhost' IDENTIFIED BY '${nextcloudPassword}';
FLUSH PRIVILEGES;";
if [ $? -eq 0 ]
then
    echo "Privileges granted"
else
    echo "Error processing : $?" >&2
fi

#    service mysql restart

nextcloud_Install_Options=""

nextcloud_Install_Options=${NEXTCLOUD_DATABASE:+--database=${NEXTCLOUD_DATABASE}}

nextcloud_Install_Options="${nextcloud_Install_Options}
    ${NEXTCLOUD_DATABASE_NAME:+--database-name=${NEXTCLOUD_DATABASE_NAME}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${NEXTCLOUD_DATABASE_HOST:+--database-host=${NEXTCLOUD_DATABASE_HOST}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${NEXTCLOUD_DATABASE_PORT:+--database-port=${NEXTCLOUD_DATABASE_PORT}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${NEXTCLOUD_DATABASE_USER:+--database-user=${NEXTCLOUD_DATABASE_USER}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${nextcloudPassword:+--database-pass=${nextcloudPassword}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${NEXTCLOUD_DATABASE_TABLE_PREFIX:+ \
    --database-table-prefix=${NEXTCLOUD_DATABASE_TABLE_PREFIX}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${NEXTCLOUD_DATABASE_ADMIN_USER:+--admin-user=${NEXTCLOUD_DATABASE_ADMIN_USER}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${adminPassword:+--admin-pass=${adminPassword}}"

nextcloud_Install_Options="${nextcloud_Install_Options}
${NEXTCLOUD_DATA_DIR:+--data-dir=${NEXTCLOUD_DATA_DIR}}"

nextcloud_Install_Options=$(echo ${nextcloud_Install_Options} | tr -s \
    '[:space:]' ' ')


# Install Nexcloud
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ  \
    maintenance:install ${nextcloud_Install_Options}

# remove all downloaded files
cd ..
rm -r $NEXTCLOUD_DIRECTORY_SOURCES
cd ${SCRIPT_DIRECTORY}

if [ -f `pwd`/installNextcloudApps.sh ]
then
    . `pwd`/installNextcloudApps.sh
fi

. `pwd`/nextcloudStrongDirectoryPermissions.sh

if [ -f /etc/${WEB_SERVER}/nextcloud.conf ]
then
    cp /etc/${WEB_SERVER}/nextcloud.conf \
        /etc/${WEB_SERVER}/${RUNNING_DATE_TIME}_nextcloud.conf
fi

# Configure Apache for nextcloud
echo "Configure ${WEB_SERVER} nextcloud.conf"
sed \
    "s/<+NEXTCLOUD_CONFIG_ServerAdmin+>/${NEXTCLOUD_CONFIG_ServerAdmin}/;
    s/<+NEXTCLOUD_CONFIG_ServerName+>/${NEXTCLOUD_CONFIG_ServerName}/" \
`pwd`/etc/${WEB_SERVER}/sites-available/nextcloud.conf > \
    /etc/${WEB_SERVER}/sites-available/nextcloud.conf

if [ ${WEB_SERVER} == "nginx" ] && [ ! -e /etc/nginx/ssl.conf ]
then
    # Configure Apache for nextcloud
    echo "Configure nginx ssl.conf"
    sed \
        "s@<+SSLCertificateFile+>@${NEXTCLOUD_CONFIG_certificateFile:-<+SSLCertificateFile+>}@
        s@<+SSLCertificateKeyFile+>@${NEXTCLOUD_CONFIG_certificateKeyFile:-<+SSLCertificateKeyFile+>}@" \
            `pwd`/etc/nginx/ssl.conf > \
            openssl dhparam -out /etc/nginx/dhparam.pem 2048
            /etc/nginx/ssl.conf
fi

#ln -s /etc/apache2/sites-available/nextcloud.conf \
#    /etc/apache2/sites-enabled/nextcloud.conf
#echo "WARNING : SSLEngine is disabled : to enable modify file /etc/apache2/ssl.conf"
#echo "Configure Apache nextcloud.conf : terminated"

if [ "${WEB_SERVER}" == "apache2" ]
then
echo "a2enmod rewrite"
    a2enmod rewrite
    echo "a2enmod rewrite : terminated"
    echo "a2enmod headers"
    a2enmod headers
    echo "a2enmod env"
    a2enmod env
    echo "a2enmod env : terminated"
    echo "a2enmod dir"
    a2enmod dir
    echo "a2enmod dir : terminated"
    echo "a2enmod mime"
    a2enmod mime
    echo "a2enmod mime : terminated"
    echo "a2enmod ssl"
    a2enmod ssl
    echo "a2enmod ssl : terminated"

    # activation ssl
    a2enmod ssl
    a2ensite nextcloud

    echo "apachectl restart"
    apachectl configtest && apachectl restart || echo "Failed restartin apache"
else
    ln -s /etc/nginx/sites-available/nextcloud.conf /etc/nginx/sites-enabled/
    cp `pwd`/etc/ngix/conf.d/* /etc/ngix/conf.d/
    sed -ibak /etc/nginx/nginx.conf 's/^\s*#\s*\(server_names_hash_bucket_size\)/\1/'
    systemctl restart nginx
fi

echo "Warning: ssl isn't properly activated, please run certbot then uncomment the contents of /etc/${WEB_SERVER}/ssl.conf"

line="*/15  *  *  *  * php -f ${NEXTCLOUD_INSTALL_DIR}/cron.php"
echo "Adding crontab entry '$line' to www-data"
(crontab -u www-data -l; echo "${line}") | crontab -u www-data -
echo "Adding crontab entry '$line' to www-data, done"


# Configure config.php

echo "cd ${NEXTCLOUD_INSTALL_DIR}/config"
cd ${NEXTCLOUD_INSTALL_DIR}/config
echo "cd ${NEXTCLOUD_INSTALL_DIR}/config : terminated"

sections=${NEXTCLOUD_CONFIG_trusted_domains:-\
    "${NEXTCLOUD_CONFIG_trusted_domains}"}
sections="${sections} 'memcache.local' => 'APCu',"
# sections=$(echo $sections | tr -s '[:space:]' ' ')

echo "Set /var/www/nexcloud/config/config.php"
sed -i.bak -e "/'trusted_domains'/,/),/d;
s@)@${sections})@;
/array(/s@,@,\n@g;" \
    -e 's/APCu/OC\\\\Memcache\\\\APCu/' \
    -e "s/^);$/  'updater.release.channel' => 'production',\n);/" \
    `pwd`/config.php

echo "sed -i.bak \"/'trusted_domains'/,/),/d;" \
     "s@)@${sections})@;" \
     "/array(/s@,@,\n@;\" `pwd`/config.php : terminated"
echo "WARNING : Take a look at /var/www/nexcloud/config/config.php"

cd ${SCRIPT_DIRECTORY}

echo "Copying nextcloud php.ini recommandations (opcache)"
if [ "${WEB_SERVER}" == "apache2" ]
then
    cat ${SCRIPT_DIRECTORY}/etc/php/7.0/apache2/php.ini >> /etc/php/7.0/apache2/php.ini
else
    cat ${SCRIPT_DIRECTORY}/etc/php/7.0/apache2/php.ini >> /etc/php/7.0/fpm/php.ini
fi

systemctl restart apache2

unset nextcloudPassword
unset adminPassword
