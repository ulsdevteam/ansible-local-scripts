#!/bin/sh
#
#
# VARS
journals_dir=/usr/local/journals
template_dir=$journals_dir/TEMPLATE
release_dir=$journals_dir/RELEASES
ojs_current_ver=$release_dir/ojs-current.tar
mysql=/usr/bin/mysql
apache_config=$journals_dir/apache-ojs-vhost.conf

# Begin
echo -n "Enter Journal's Full DNS name: "
read j_dns
echo -n "Enter Journal's Name: "
read j_name
echo -n "Enter Journal's Short Name: "
read j_short
echo -n "Enter Mysql root's Password: "
stty -echo
read mysql_pw
stty echo


echo "Creating New Journal: $j_name"

j_home=$journals_dir/$j_dns
j_vhost=$j_home/vhost.conf
j_htdocs=$j_home/htdocs
j_files=$j_home/files

echo "  Making journal directory: $journals_dir/$j_dns."
mkdir $j_home

echo "  Copying Template over."
cp -Rp $template_dir/* $j_home

echo "  Updating vhost: $j_vhost."
sed "s/{name}/$j_dns/g" $j_vhost > $j_vhost.new
mv $j_vhost.new $j_vhost
sed "s/{journal}/$j_name/g" $j_vhost > $j_vhost.new
mv $j_vhost.new $j_vhost

echo "  Extracting OJS tar file: $ojs_current_ver"
echo "    To: $j_htdocs"
/usr/sfw/bin/gtar xpf $ojs_current_ver -C $j_htdocs
cd $j_htdocs
ln -s ojs-* ojs

echo "  Setting file ownership."
chown -R apache:apache $j_files

j_db_ojs=$j_short
j_db_pwd=`tr -dc '[:alnum:]' < /dev/urandom | fold -w 32 | head -1`

echo "  Creating Databases and accounts."
$mysql -u root --password=$mysql_pw <<EOFMYSQL
create database $j_db_ojs default character set utf8 default collate utf8_general_ci;
grant ALL ON $j_db_ojs.* TO $j_short@localhost IDENTIFIED BY '$j_db_pwd';
EOFMYSQL

echo "  Updating OJS Apache config file."
echo "Include $j_vhost" >> $apache_config

echo "  Creating a default config.inc.php as config.NEW.inc.php."
echo "  (You need to review this file AFTER running the web install, and at least set the Installed parameter before moving it to config.inc.php)"
NEWCONF=$j_htdocs/ojs/config.NEW.inc.php
cp $j_htdocs/ojs/config.inc.php $NEWCONF
sed "s/^base_url = .*/base_url = http:\/\/$j_dns\/ojs/" $NEWCONF > $NEWCONF.tmp
mv $NEWCONF.tmp $NEWCONF
sed "s/^username = .*/username = $j_short/" $NEWCONF > $NEWCONF.tmp
mv $NEWCONF.tmp $NEWCONF
sed "s/^password = .*/password = $j_db_pwd/" $NEWCONF > $NEWCONF.tmp
mv $NEWCONF.tmp $NEWCONF
sed "s/^name = .*/name = $j_short/" $NEWCONF > $NEWCONF.tmp
mv $NEWCONF.tmp $NEWCONF
sed "s/^repository_id = .*/repository_id = ojs.$j_dns/" $NEWCONF > $NEWCONF.tmp
mv $NEWCONF.tmp $NEWCONF

echo "Done."
echo "Your database password is: $j_db_pwd"
 
