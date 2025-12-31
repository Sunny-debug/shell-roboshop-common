#!/bin/bash

source ./common.sh
check_root
app_name=redis

dnf module disable $app_name -y &>>$LOG_FILE

dnf module enable redis:7 -y &>>$LOG_FILE

dnf install $app_name -y &>>$LOG_FILE
VALIDATE $? ' Redis Installed'

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
sed -i 's/^protected-mode[[:space:]]\+yes/protected-mode no/' /etc/redis/redis.conf

systemctl enable redis &>>$LOG_FILE

systemctl start $app_name &>>$LOG_FILE
VALIDATE $? ' Successfully Installed '

print_total_time