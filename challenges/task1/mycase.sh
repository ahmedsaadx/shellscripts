#!/usr/bin/bash
read -p 'enter your char ' char
case $char in 
    [A-Z]) echo 'upper case' ;;
    [a-z]) echo 'lower case' ;;
    [0-9]) echo 'number ' ;;
    *) echo 'nothing' ;;
esac    
