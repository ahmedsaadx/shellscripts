#!/usr/bin/bash
shopt -s extglob
read -p 'enter your string ' string
case $string in 
    +([A-Z])) echo 'upper case' ;;
    +([a-z])) echo 'lower case' ;;
    +([A-Za-z0-9])) echo 'mix' ;;
    +([0-9])) echo 'number ' ;;
    *) echo 'no thing ';; 
esac    
