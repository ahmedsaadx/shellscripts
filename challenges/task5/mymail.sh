#!/usr/bin/bash




for user in `grep bash /etc/passwd | cut -d: -f 1 `
do 
mailx user < mtemplate
echo "mail sended to $user"
done
