#!/bin/bash

#General VARS
GIT_TOKEN="826F_Xx3zPgiZo7MSQkx"
LIST=`cat /home/ec2-user/list | awk '{print $1}'`
WP_DIR=/var/www/html/
DOMAIN_TYPE="html-sites"
ID=6

check_dir () {
if [ -d "$WP_DIR" ]; then
cd $WP_DIR
else
echo "$WP_DIR - Does not exits, check path"
exit 255
fi
}

create_dump () {
DB_NAME=`cat $WP_DIR/$SITENAME/wp-config.php | grep "DB_NAME" | awk -F", '" '{print $2}' | awk -F"'" '{print $1}'`
DB_USER=`cat $WP_DIR/$SITENAME/wp-config.php |grep "DB_USER" | awk -F", '" '{print $2}' | awk -F"'" '{print $1}'`
DB_PASSWORD=`cat $WP_DIR/$SITENAME/wp-config.php |grep "DB_PASSWORD" | awk -F", '" '{print $2}' | awk -F"'" '{print $1}'`
DB_HOST=`cat $WP_DIR/$SITENAME/wp-config.php |grep "DB_HOST" | awk -F", '" '{print $2}' | awk -F"'" '{print $1}'`
if [ -f "$WP_DIR/$SITENAME/wp-config.php" ]; then
/usr/bin/mysqldump -h $DB_HOST -u $DB_USER -B $DB_NAME -p$DB_PASSWORD > $WP_DIR/$SITENAME/$DB_NAME.sql
else
echo "$DB_NAME - No wp-config.php file, please check"
exit 255
fi
}

create_deploy_repo () {
cd $WP_DIR/${SITENAME} && #rm .bash
curl --header "PRIVATE-TOKEN: $GIT_TOKEN" -X POST "http://satellites-git.uncomp.com/api/v3/projects?name=$GIT_PROJECT&namespace_id=$ID" 2>/dev/null &&
git init && git remote add origin git@satellites-git.uncomp.com:$DOMAIN_TYPE/$GIT_PROJECT.git
git add . &&
git commit -m "Added $SITENAME" &&
git push -u origin master &&
echo "Domain $SITENAME been pushed to repository ===> $GIT_PROJECT <==="
}


for SITENAME in $LIST;do
GIT_PROJECT=`echo $SITENAME | sed 's/\./\-/g'`
check_dir
create_dump
create_deploy_repo
done
