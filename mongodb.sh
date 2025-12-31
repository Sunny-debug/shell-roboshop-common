#!/bin/bash

source ./common.sh
check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo Repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabled Service"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Started Service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing Remote Connections to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in $Y $TOTAL_TIME Seconds $N"