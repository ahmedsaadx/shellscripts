#!/bin/bash 

#################################################
#                                               #
# A shell script to install Ansible on CentOS   #
#                                               #
#################################################

# check if the current user is root
#if [[ $(/usr/bin/id -u) != "0" ]]; then
#    echo -e "This looks like a 'non-root' user.\nPlease switch to 'root' or run with sudo .\ncreate by mrkernel ."
#    exit
#fi

server_name=$(hostname)

function memory_check() {
    echo ""
	echo "Memory usage on ${server_name} is: "
	free -h
	echo ""
}

function cpu_check() {
    echo ""
	echo "CPU load on ${server_name} is: "
    echo ""
	uptime
    echo ""
}

function tcp_check() {
    echo ""
	echo "TCP connections on ${server_name}: "
    echo ""
	cat  /proc/net/tcp | wc -l
    echo ""
}

function kernel_check() {
    echo ""
	echo "Kernel version on ${server_name} is: "
	echo ""
	uname -r
    echo ""
}

function all_checks() {
	memory_check
	cpu_check
	tcp_check
	kernel_check
}



##
# Color Functions
##


menu(){
echo -ne "
(Enter Your Number)
1)Memory usage
2) CPU load
3) Number of TCP connections
4) Kernel version
5) Check All
0) Exit
 Choose an option: "
        read a
        case $a in
	        1) memory_check ; menu ;;
	        2) cpu_check ; menu ;;
	        3) tcp_check ; menu ;;
	        4) kernel_check ; menu ;;
	        5) all_checks ; menu ;;
			0) exit 0 ;;
			*) echo -e "Wrong option.";;
        esac
}

menu
	
