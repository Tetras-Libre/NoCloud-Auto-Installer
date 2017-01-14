#!/bin/bash - 
#===============================================================================
#
#          FILE: InstallMySql.sh
# 
#         USAGE: ./InstallMySql.sh 
# 
#   DESCRIPTION: Install MySql and create root user for MySql. It
#   genereates random password to root user and saves it to /root/.my.cnf
#   file. The .my.cnf file permissions are the following : 0600. Once the
#   script is read mysql service is started.
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: SEBASTIEN CURT (), sebastien.curt@tetras-libre.fr
#  ORGANIZATION: 
#       CREATED: 01/12/2017 09:50:24
#      REVISION: 0.0.1 
#===============================================================================

set -o nounset                              # Treat unset variables as an error


###########################################################################
# 1. Install MySql
# 2. Save root password to file /root/.my.cnf
# 3. Configure MySql with mysql_secure_installation
# 4. Start mysql service
###########################################################################
DEBIAN_FRONTEND='noninteractive' apt-get -qq install mysql-server \
    apg expect

export mysqlPassword="$(apg -q -a 0 -n 1 -m 21 -E "\"\'\`" -M NCL)"

# Save in Root home directory connection configuration
if [ ! -e "${HOME}/.my.cnf" ]
then
    {
    echo "[client]"
    echo "user=root"
    echo "password=${mysqlPassword}"
    } | tee '/root/.my.cnf' > "${HOME}/.my.cnf";
    chmod 400 '/root/.my.cnf' "${HOME}/.my.cnf";
fi

service mysql start


configureMySQLFile="/root/configureMySQL.sh"
# build expected script to run
{
echo "spawn $(which mysql_secure_installation)"

echo "expect \"Enter current password for root (enter for none):\""
echo "send \"\r\""

echo "expect -re \"Set root password\?.*\""
echo "send \"y\r\""

echo "expect -re \"New password:.*\""
echo "send \"${mysqlPassword}\r\""

echo "expect \"Re-enter new password:\""
echo "send \"${mysqlPassword}\r\""

echo "expect -re \"Remove anonymous users\?.*\""
echo "send \"y\r\""

echo "expect -re \"Disallow root login remotely\?.*\""
echo "send \"n\r\""

echo "expect -re \"Remove test database and access to it\?.*\""
echo "send \"y\r\""

echo "expect -re \"Reload privilege tables now\?.*\""
echo "send \"y\r\""
} > ${configureMySQLFile}

# Run Expect script.
# This runs the "mysql_secure_installation" script which removes insecure
# defaults.
expect  ${configureMySQLFile}

# allow PHP to access to mysql
mysql -e "
GRANT ALL PRIVILEGES on *.* to 'root'@'localhost' IDENTIFIED BY 
'${mysqlPassword}';
GRANT ALL PRIVILEGES on *.* to 'root'@'127.0.0.1' IDENTIFIED BY
'${mysqlPassword}';
FLUSH PRIVILEGES;"

# Cleanup
rm -v ${configureMySQLFile} # Remove the generated Expect script

unset configureMySQLFile
unset mysqlPassword

echo "MySQL setup completed. Insecure defaults are gone. Please remove"
echo " this script manually when you are done with it (or at least "
echo "remove the MySQL root password that you put inside it."
