#!/usr/bin/bash

sqr(){
<<comment  
if [ $# != 0 ];then
    echo "you must enter argument "
    echo
     x=$1
    return $x
 else 
    echo "ok"
comment
 typeset  squre
 (( squre = $1 ** 2 ))
  
 echo $squre  
 #typeset x 
 #x=(( $1 ^ 2 ))
 #return $x
}

sqr $1 
