#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

echo "Please enter DB password"
read -s mysql_root_password

VALIDATE() {
    if [ $1 -ne 0 ]
    then
    echo -e "$R $2....FAILURE $N"
    exit 1
    else
    echo -e "$G $2....SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access"
    exit 1
else
    echo -e "$R you are super user $N"
fi

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>LOGFILE

if [ $? -ne 0 ]
then
useradd expense &>>LOGFILE
VALIDATE $? "Creating expense user"

else
echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>LOGFILE
VALIDATE $? "Creatomh app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading backend code"

cd /app 
rm -rf /app/*
unzip /tmp/backend.zip &>>LOGFILE
VALIDATE $? "Unzip the backend code"

npm install &>>LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "Here, Daemon reloaded"

systemctl start backend &>>LOGFILE
VALIDATE $? "Starting backend service"

systemctl enable backend &>>LOGFILE
VALIDATE $? "Enabling backend service"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "Installing MYSQL CLIENT"

mysql -h db.bhuvankarri.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>LOGFILE
VALIDATE $? "Restarting backend"









