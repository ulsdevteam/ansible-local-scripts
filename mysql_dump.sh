#!/bin/sh
#
# User Entered Variables
USER=backup
PASSWORD=purpleturkeycap
BACKUPDIR=/usr/local/mysqlbackup/backups
MYSQLDUMP=/usr/bin/mysqldump
GZIP=/bin/gzip

# Created Variables
DATABASE=${1}
HOST=${2}
NOW=`date '+%H%M%S-%d%m%Y'`
BACKUPFILE=${BACKUPDIR}/${HOST}.${DATABASE}.${NOW}.sql

# Execute Backup

if [ -d ${BACKUPDIR} ]
then
	if [ $# -eq 1 ]
	then
        	${MYSQLDUMP} -u ${USER} --password=${PASSWORD} ${DATABASE} > ${BACKUPFILE}
	fi
	if [ $# -eq 2 ]
	then
		${MYSQLDUMP} -u ${USER} --password=${PASSWORD} -h ${HOST} ${DATABASE} > ${BACKUPFILE}
	fi
	if [ -e ${BACKUPFILE} ]
	then
        	${GZIP} ${BACKUPFILE}
	fi
fi

