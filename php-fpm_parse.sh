#!/bin/bash

LOG_FILE="php-fpm_slow.log" # Update this path to match your slow log file
SCRIPTS=$(grep  'script_filename =' $LOG_FILE | cut -d= -f2 | sort | uniq)

for SCRIPT in $SCRIPTS; do
  echo -e  "$SCRIPT"
done


echo -e "\n"
echo "Slow requests grouped by function call" 
cat $LOG_FILE | grep  0x00007  | grep -v -e "--" | cut -c 22- | sort | uniq -c | sort -nr

