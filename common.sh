#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.dawgs.online
mkdir -p $LOGS_FOLDER
echo "Script execution started at: $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "ERROR:: Please run this script with root privelege"
        exit 1 # failure is other than 0
    fi
}

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Creating USER"
    else   
        echo -e "USER already exists $Y ... SKIPPING ... $N"
    fi
    mkdir -p /app 
    VALIDATE $? "Creating App Dir"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name Application"

    cd /app 
    VALIDATE $? "Changing to App Dir"

    rm -rf /app/*
    VALIDATE $? "Removing Existing Code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzip $app_name"
}

Nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling Nodejs"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling Nodejs 20"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing Nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Install Dep" 
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/catalogue.service
    VALIDATE $? "Systemctl Service"
    systemctl daemon-reload
    VALIDATE $? "Daemon Reload"

    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable $app_name" 
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarted $app_name"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script executed in $Y $TOTAL_TIME Seconds $N"
}

