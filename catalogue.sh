#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
Nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing Mongo Client"

INDEX=$(mongosh mongodb.dawgs.online --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load $app_name products"
else
    echo -e "$app_name products already loaded ... $Y SKIPPING $N"
fi

app_restart
print_total_time