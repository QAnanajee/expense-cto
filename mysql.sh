#!/bin/bash

source ./common.sh

check_root

echo "Please enter DB password"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
#VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
#VALIDATE $? "Enable mysql server"

systemctl start mysqld &>>$LOGFILE
#VALIDATE $? "Start mysql server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

# Bellow code will be useful for idempotent nature
mysql -h db.bhuvankarri.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    #VALIDATE $? "MySql root password setup"
else
    echo -e "MySql root password is already setup.. $Y SKIPPING $N"
fi





