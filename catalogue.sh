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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current NodeJS" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling NodeJS" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18"

Useradd roboshop

VALIDATE $? "creating roboshop user" 

mkdir /app

VALIDATE $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue application" 

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" 

npm install -y &>> $LOGFILE

VALIDATE $? "installing dependencies" 

# use absolute, because catalogue.service exists there
cp home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue demon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start catalogue"

cp home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host $MONGODG_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into MONGODB"
