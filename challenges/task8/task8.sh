#!/usr/bin/bash


select a in ls 'ls -a' exit 
do
 case $a in
    ls) ls
    ;; 
    "ls -a" ) ls -a
    ;;
    "exit")  break 
    ;;
    *) echo 'error'
    ;;
 esac  
    
done     





: '
while [ $a = 'ahmed' ]
   do
    echo 'ahmed'
    break
   done
   while [ $a = 'saad' ]
    do
    echo 'saad'
    break
    done
    while [[  $a != 'ahmed'  &&  $a != 'saad'  ]]
    do 
    echo 'good bye'
    exit
    done
    
 '
