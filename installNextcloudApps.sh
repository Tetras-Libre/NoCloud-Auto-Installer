NEXTCLOUD_INSTALL_DIR="/var/www/nextcloud/"
NEXTCLOUD_APPS_DIR="${NEXTCLOUD_INSTALL_DIR}apps/"

# Install tasks
application="Tasks"
echo "INSTALL ${application}"
echo "\tDownload ${application} from https://github.com/nextcloud/tasks/releases/download/v0.9.4/tasks.tar.gz"
wget "https://github.com/nextcloud/tasks/releases/download/v0.9.4/tasks.tar.gz"
echo "\tDownload ${application} : terminated"
echo "\tExtract ${application}"
tar xzf ${PWD}/tasks.tar.gz
echo "\tExtract ${application} : terminated"
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
cp -r --verbose ${PWD}/tasks ${NEXTCLOUD_APPS_DIR}
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated"
chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}tasks
echo "\tEnable ${application}"
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable tasks
echo "\tEnable ${application} : terminated"

# Install news
application="News"
echo "INSTALL ${application}"
echo "\tDownload ${application} from https://github.com/nextcloud/news/releases/download/10.1.0/news.tar.gz"
wget "https://github.com/nextcloud/news/releases/download/10.1.0/news.tar.gz"
echo "\tDownload ${application} : terminated"
echo "\tExtract ${application}"
tar xzf ${PWD}/news.tar.gz
echo "\tExtract ${application} : terminated"
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
cp -r --verbose ${PWD}/news ${NEXTCLOUD_APPS_DIR}
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated"
chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}news
echo "\tEnable ${application}"
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable news
echo "\tEnable ${application} : terminated"

# Install direct_menu
application="Direct_menu"
echo "INSTALL ${application}"
echo "\tDownload ${application} from https://github.com/juliushaertl/direct_menu/releases/download/0.9.3/direct_menu.tar.gz"
wget "https://github.com/juliushaertl/direct_menu/releases/download/0.9.3/direct_menu.tar.gz"
echo "\tDownload ${application} : terminated"
echo "\tExtract ${application}"
tar xzf ${PWD}/direct_menu.tar.gz
echo "\tExtract ${application} : terminated"
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
cp -r --verbose ${PWD}/direct_menu ${NEXTCLOUD_APPS_DIR}
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated"
chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}direct_menu
echo "\tEnable ${application}"
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable direct_menu 
echo "\tEnable ${application} : terminated"

# Install keeweb
application="Keeweb"
echo "INSTALL ${application}"
echo "\tDownload ${application} from https://github.com/jhass/nextcloud-keeweb/releases/download/v0.3.0/keeweb-0.3.0.tar.gz"
wget "https://github.com/jhass/nextcloud-keeweb/releases/download/v0.3.0/keeweb-0.3.0.tar.gz"
echo "\tDownload ${application} : terminated"
echo "\tExtract ${application}"
tar xzf ${PWD}/keeweb-0.3.0.tar.gz
echo "\tExtract ${application} : terminated"
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
cp -r --verbose ${PWD}/keeweb ${NEXTCLOUD_APPS_DIR}
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated"
chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}keeweb
echo "\tEnable ${application}"
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable keeweb
echo "\tEnable ${application} : terminated"

# Install calendar
application="Calendar"
echo "INSTALL ${application}"
echo "\tDownload ${application} from https://github.com/nextcloud/calendar/releases/download/v1.4.1/calendar.tar.gz"
wget "https://github.com/nextcloud/calendar/releases/download/v1.4.1/calendar.tar.gz"
echo "\tDownload ${application} : terminated"
echo "\tExtract ${application}"
tar xzf ${PWD}/calendar.tar.gz
echo "\tExtract ${application} : terminated"
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
cp -r --verbose ${PWD}/calendar ${NEXTCLOUD_APPS_DIR}
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated"
chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}calendar
echo "\tEnable ${application}"
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable calendar
echo "\tEnable ${application} : terminated"

# Install contacts
application="Contacts"
echo "INSTALL ${application}"
echo "\tDownload ${application} from https://github.com/nextcloud/contacts/releases/download/v1.5.2/contacts.tar.gz"
wget "https://github.com/nextcloud/contacts/releases/download/v1.5.2/contacts.tar.gz"
echo "\tDownload ${application} : terminated"
echo "\tExtract ${application}"
tar xzf ${PWD}/contacts.tar.gz
echo "\tExtract ${application} : terminated"
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
cp -r --verbose ${PWD}/contacts ${NEXTCLOUD_APPS_DIR}
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated"
chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}contacts
echo "\tEnable ${application}"
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable contacts
echo "\tEnable ${application} : terminated"

# Install Markdown editor
application="markdown"
echo "INSTALL ${application}"
echo "\tDownload ${application} from https://github.com/icewind1991/files_markdown/releases/download/v1.0.0/files_markdown.tar.gz"
wget "https://github.com/icewind1991/files_markdown/releases/download/v1.0.0/files_markdown.tar.gz"
echo "\tDownload ${application} : terminated"
echo "\tExtract ${application}"
tar xzf ${PWD}/files_markdown.tar.gz
echo "\tExtract ${application} : terminated"
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
cp -r --verbose ${PWD}/files_markdown ${NEXTCLOUD_APPS_DIR}
echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated"
chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}files_markdown
sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable files_markdown
echo "\tEnable ${application} : terminated"

rm -r ${PWD}/tasks* ${PWD}/news* ${PWD}/direct_menu* ${PWD}/keeweb* \
    ${PWD}/calendar* ${PWD}/contacts* ${PWD}/files_markdown*

unset NEXTCLOUD_INSTALL_DIR
unset NEXTCLOUD_APPS_DIR
