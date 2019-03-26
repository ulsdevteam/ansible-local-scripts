#!/bin/bash

DATE=$(date +"%m%d%y")
SERVER=$(hostname)
DESTDIR=/home/mysql_backup/mysqlbackup/uls_backups
DBMGMT=db-mgmt-01.library.pitt.edu
BACKUPFILE=/home/mysql_backup/backup.tar.gz

scp $BACKUPFILE $DBMGMT:$DESTDIR/$SERVER.backup.$DATE.tar.gz
