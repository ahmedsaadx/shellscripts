#!/usr/bin/bash
<<comment
path="$HOME/"


for i in $path
do 
   if [ -f $i ]; then
       echo $path/backup/
      cp $i /tmp/       
   fi    
done   
comment



var=`ls $1`
for i in $var
do 
 if [ -f $i ] ;then
  cp $i backup/   
 else
  echo 'please enter file type only '
  fi
done
tar cvf backup.tar backup/   
