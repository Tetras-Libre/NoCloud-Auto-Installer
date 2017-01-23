#!/bin/bash

# Copyright (C) 2015  Beniamine, David <David@Beniamine.net>
# Author: Beniamine, David <David@Beniamine.net>
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

recipient="root"
level=info
date="$(date +%y%m%d_%H%M)"
archiveFile="HealthReport-$date.tar.xz"
logdir="/var/log"
# Log to add if we are in alert mode
alertfiles="$logdir/mysql.log $logdir/faillog \
    $logdir/daemon.log $logdir/auth.log $logdir/kern.log"
# Log files to always include
files="$logdir/fail2ban.log"
# No need for an actual random number as we know this sentence will never
# appear in the mail
BOUNDARY="unique-boundary-42"
BOUNDARY2="unique-boundary-24"


usage()
{
    echo "Usage $0 [options]"
    echo "-h        Display this help and quit"
    echo "-l level  Set the report level {info,warning, alert}, default: info"
    echo "-f list   include file listeds must be between \"\""
    echo "-m message Add a message to the e-mail"
}

# Switch to alert level if needed
set_level()
{
    # Check for dead services => level to alert
    services=$(/bin/systemctl --failed --all)
    dead_srv=$(echo "$services" | grep "mysql\|apache\|ssh\|fail2ban")
    if [ ! -z "$dead_srv" ]
    then
        text="$text\nlevel switch to alert because an important service is down.\nold level: $leveldead\nservices: $dead_srv"
        level="alert"
    fi
    subject="[$level] Health report $date for $(hostname)"
}

# Create archive file
create_archive()
{
    if [ "$level" != "info" ]
    then
        files="$files $alertfiles"
    fi

    tar cvJf $archiveFile $files
    ATT_MIMETYPE=$(file -ib $archiveFile | cut -d";" -f1)     # detect mime type
    ATT_ENCODED=$(base64 < $archiveFile)  # encode attachment
    rm $archiveFile
}

list_upgradable_packages()
{
    /usr/bin/aptitude update > /dev/null 2>&1
    res=$(/usr/bin/aptitude search ~U)
    if [ -z "$res" ]
    then
        res="All packages are up to date"
    fi
    echo $res | sed 's/ i /\ni /g'
}
# Execute the given command and print it as code
do_cmd()
{
    $@ | sed 's/^\(.*\)$/\t\1/g'
}

# Actual content of the mail, must be markdown format
generate_markdown_content()
{
    cat <<-EOF
# Health report from $(hostname)

$(echo -e "$text")

## System status

### Uptime

$(do_cmd uptime)

### IP

$(do_cmd $(dirname $0)/getip.sh)

### Is system running ?

$(do_cmd /bin/systemctl is-system-running)

### Upgradable packages

$(do_cmd list_upgradable_packages)

### Services

#### Failed

$(do_cmd echo "$services")

#### Requiring restart

$(do_cmd /usr/sbin/checkrestart)

#### Ufw

$(do_cmd /usr/sbin/ufw status numbered)

## System usage

### Users

$(do_cmd who -a)

### Memory

$(do_cmd free -h)

### Disk

$(do_cmd df -h)

### CPU

#### Freq

$(do_cmd cpufreq-info)

#### Sensors

$(do_cmd sensors)

## Contrab

$(do_cmd crontab -l)

Best regards,
EOF
}

generate_mail_content()
{
    # Bufferize the markdow version
    if [ -z "$markdown_content" ]
    then
        markdown_content=$(generate_markdown_content | sed 's/$/\\n/g')
    fi
    # print the requested verions
    if [ "$1" == "html" ]
    then
        echo -e "$markdown_content" | /usr/bin/pandoc --standalone
    else
        echo -e "$markdown_content"
    fi
}
# Generate a multipart mail with the report and attachement, format:
# multipart / mixed
#   |- multipart / alternative
#       |- text / plain
#       |- text / html
#   |- attachement
generate_mail()
{
    cat <<-EOF
To: $recipient
Subject: $subject
Auto-Submitted: auto-generated
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="$BOUNDARY"

--$BOUNDARY
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="$BOUNDARY2"
Content-Disposition: inline

--$BOUNDARY2
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

$(generate_mail_content plain)
--$BOUNDARY2
MIME-Version: 1.0
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: 7bit

$(generate_mail_content html)
--$BOUNDARY2--
--$BOUNDARY
MIME-Version: 1.0
Content-Disposition: attachment; filename="$archiveFile"
Content-Transfer-Encoding: base64
Content-Type: $ATT_MIMETYPE; name="$archiveFile"

$ATT_ENCODED
--$BOUNDARY--

EOF
}

while getopts "hl:f:m:" opt; do
    case $opt in
        f)
            files="$files $OPTARG"
            ;;
        l)
            level=$OPTARG
            ;;
        h)
            usage
            exit 0
            ;;
        m)
            text="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$opt"
            usage
            exit 1
            ;;
    esac
done

set_level
create_archive
generate_mail | /usr/sbin/sendmail -t
