#!/bin/bash


if [[ $(id -u ) != 0 ]]; then
    echo -e 'you should be root to run this script or run with sudo '
     exit 0
 fi  



#install updates
echo -ne " install updates ######"
sleep .5
echo -ne '##' 
sleep .5 
echo -ne '###'
echo '###'
apt-get update 1> /tmp/install_.tmp
apt-get upgrade -y 1> /tmp/install_.tmp
echo -e 'update installed \n'
#install tools
echo -ne " install tools ######"
sleep .5
echo -ne '##' 
sleep .5 
echo -ne '###'
echo '###'
apt install vlc bleachbit tmux yt-dlp git keepassxc vim qbittorrent tor virtualbox tmux telegram-desktop wireshark nmap docker.io net-tools gcc make code -y
echo -e 'update installed \n'

#config git
echo -ne " config git  ######"
sleep .5
echo -ne '##' 
sleep .5 
echo -ne '###'
echo -ne '###\n'
git config --global user.name 'ahmedsaadx'
git config --global user.email 'ahmeddsaadd188@gmail.com'
git config --global alias.s 'status'
git config --global alias.c 'commit'
git config --global alias.last 'log -1 HEAD'
git config --global core.editor 'vim'
git config --global core.defauktBranch 'main'
 echo -e '\n'
echo '****done*****' 


    