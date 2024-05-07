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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enable mysql server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Start mysql server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

# Bellow code will be useful for idempotent nature
mysql -h db.bhuvankarri.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySql root password setup"
else
    echo -e "MySql root password is already setup.. $Y SKIPPING $N"
fi





