#!/bin/bash

source ./common.sh
check_root
cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Started Installing RabbitMQ"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabled RabbitMQ"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Started RabbitMQ Server"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "Added Users"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Permissions are Set"

print_total_time