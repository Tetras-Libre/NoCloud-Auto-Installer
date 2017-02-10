
# Copyright (C) 2017  Tetras Libre <admin@tetras-libre.fr>
# Author: Curt, Sebastien <Sebastien.Curt@tetras-libre.fr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

NEXTCLOUD_INSTALL_DIR="/var/www/nextcloud/"
NEXTCLOUD_APPS_DIR="${NEXTCLOUD_INSTALL_DIR}apps/"

# Take 2 parameters: app_id app_url
install_app () {
    application=$1
    url=$2
    archive=`echo $url | sed 's@^.*/\(.*\)$@\1@'`
    echo "INSTALL ${application}"
    echo "\tDownload ${application} from ${url}"
    wget "${url}"
    echo "\tDownload ${application} : terminated, code $?"
    echo "\tExtract ${application}"
    tar xzf ${PWD}/${archive}
    echo "\tExtract ${application} : terminated, code $?"
    echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR}"
    cp -r --verbose ${PWD}/${application} ${NEXTCLOUD_APPS_DIR}
    echo "\tMove extracted file to ${NEXTCLOUD_APPS_DIR} : terminated, code $?"
    chown -R www-data:www-data ${NEXTCLOUD_APPS_DIR}${application}
    sudo -u www-data php ${NEXTCLOUD_INSTALL_DIR}occ app:enable ${application}
    echo "\tEnable ${application} : terminated, code $?"
    rm -r ${PWD}/${application}*
}

# Install tasks
install_app "tasks" "https://github.com/nextcloud/tasks/releases/download/v0.9.4/tasks.tar.gz"

# Install news
install_app "news" "https://github.com/nextcloud/news/releases/download/10.1.0/news.tar.gz"

# Install direct_menu
install_app "direct_menu" "https://github.com/juliushaertl/direct_menu/releases/download/0.9.3/direct_menu.tar.gz"

# Install keeweb
install_app "keeweb" "https://github.com/jhass/nextcloud-keeweb/releases/download/v0.3.0/keeweb-0.3.0.tar.gz"

# Install calendar
install_app "calendar" "https://github.com/nextcloud/calendar/releases/download/v1.4.1/calendar.tar.gz"

# Install contacts
install_app "contacts" "https://github.com/nextcloud/contacts/releases/download/v1.5.2/contacts.tar.gz"

# Install Markdown editor
install_app "files_markdown" "https://github.com/icewind1991/files_markdown/releases/download/v1.0.0/files_markdown.tar.gz"

# Install Markdown editor
install_app "mail" "https://github.com/nextcloud/mail/releases/download/nightly-20170117/mail.tar.gz"


unset NEXTCLOUD_INSTALL_DIR
unset NEXTCLOUD_APPS_DIR
