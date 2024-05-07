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

dnf install nginx -y &>>LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOGFILE
VALIDATE $? "Download frontend code"

cd /usr/share/nginx/html &>>LOGFILE
VALIDATE $? "Go to file..."

unzip /tmp/frontend.zip &>>LOGFILE
VALIDATE $? "Extracting frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>LOGFILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>LOGFILE
VALIDATE $? "Restarting nginx"






