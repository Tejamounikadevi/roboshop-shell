#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=172.31.33.218

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2 ... $R FAILED $N"
   else
        echo -e "$2 ... $G SUCCESS $N"
   fi
}

if [ $ID -ne 0 ]
then    
    echo -e "$R ERROR: : Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "you are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y

VALIDATE $? "Disabling current NodeJS" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling NodeJS" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing NodeJS:18" &>> $LOGFILE

Useradd roboshop

VALIDATE $? "creating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue application" &>> $LOGFILE

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE $? "installing dependencies" &>> $LOGFILE

# use absolute, because catalogue.service exists there
cp catalogue.service home/centos/roboshop-shell/etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue demon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start catalogue"

cp home/centos/roboshop-shellmongo.repo /etc/systemd/system/catalogue.service

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y

VALIDATE $? "Installing mongodb client"

mongo --host $MONGODG_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into MONGODB"
