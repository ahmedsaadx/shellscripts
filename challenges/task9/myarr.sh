#!/usr/bin/bash
echo -n "enter your element num "
read x
typeset -i arr
i=0
while (( $i < $x  ))
do
 read -p  "enter your num " value
 
 i=$(($i + 1))
 
 arr[$i]=$value
 
done
echo ${arr[@]}
