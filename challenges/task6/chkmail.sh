#!/usr/bin/bash

user="$USER"
var=`cat /var/mail/mrkernel | wc -l`
while(true)
do 
if  [ $var  !=  `cat /var/mail/mrkernel | wc -l ` ];
then
  echo ' mail received'
   cp /var/mail/mrkernel $var
  sleep 10
else
  echo 'not mail received'
  sleep 10
fi 
done  



