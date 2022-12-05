#!/bin/bash


if [[ $(/usr/bin/id -u) != "0" ]] ; then
	echo -e "This looks like a 'non-root' user.\nPlease switch to 'root' or run with sudo\ncreate by MrKernel "
	exit  
fi

echo -ne  "
######################################################
#                                                    #
# A shell script to install devops tools on CentOS   #
#              BY MrKernel                           #
#                                                    #
###################################################### "

function update_upgrade(){
	echo""
	echo -e " update and upgrade your device programs \n"

	 yum -y update
	 yum -y upgrade
	 yum -y install epel-release yum-utils
	 yum -y update
       echo ""

}

function install_ansible(){
	echo ""
	echo -e " installing ansible ########\n"
	yum -y install ansible
	echo ""
}

function install_terraform(){
	echo ""
	echo -e " installing terraform #####\n"
	yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
	yum -y install terraform
	echo ""
}

function install_awstools(){
	echo ""
	echo -e " installing aws tools ###\n"
	yum install awscli -y
	echo ""
}

function install_docker(){
        echo ""
        echo -e " installing docker ###\n"
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
	echo ""
}

function install_webservers(){
        echo ""
        echo -e " installing apache nginx ###\n"
        yum install httpd -y    nginx tomcat  tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc
	systemctl disable nginx.service tomcat.service
	systemctl stop nginx.service tomcat.service
        echo ""
}

function all_services(){
	echo ""
	install_ansible
	install_terraform
	install_awstools
	install_docker
	install_webservers
}

menu(){
echo -ne "
(enter number only) 
1) Install ansible
2) Install terraform
3) Install aws tools
4) Install docker
5) Install web servers 'apache , ngiex,tomcat'
6) Install all tools
0) Exit 
choose an option:"
    read a
    case $a in
            1) install_ansible;menu;;
            2) install_terraform;menu;;
            3) install_awstools;menu;;
            4) install_docker;menu;;
            5) install_webservers;menu;;
            6) all_services;menu;;
            0) exit 0 ;;
            *) echo -e "wrong choice lead  you to wrong way.";;
     esac
}


echo -ne "\nyour device need to update packages \n 
if you went to update your packages \n             
enter 1 to continue ,\n 
or 0 for Exit\n
enter your choose : "	

read b

if [ $b -eq 1 ]  ; then
   	echo -e " update your packages \n"
   	update_upgrade
   	menu
elif [ $b -eq 0 ] ; then
   	echo -e "nice meet you my friend\n"	
   	exit 0 
fi

