#!/bin/bash
API_TOKEN=""
CHAT_ID=""
HOSTNAME=`hostname`
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` \"text message\""
  exit 0
fi

if [ -z "$1" ]
  then
    echo "Add message text as second arguments"
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "You can pass only one argument. For string with spaces put it on quotes"
    exit 0
fi

curl -s --data "text=$HOSTNAME>>>>>$1" --data "chat_id=$CHAT_ID" 'https://api.telegram.org/bot'$API_TOKEN'/sendMessage' > /dev/null
