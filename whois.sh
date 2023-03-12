#!/usr/bin/bash
echo  "domain name : "
read -r  domain_name
RED='\033[0;31m'
NC='\033[0m'
domain_regex="^([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}$"

if [[ $domain_name =~ $domain_regex ]]; then 
	whois_info=$(whois $domain_name)
	creation_date=$(echo "$whois_info" | grep -i 'Creation Date:' | awk -F': ' '{print $2}')
	expiration_date=$(echo "$whois_info" | grep -i 'Expiry Date:' | awk -F': ' '{print $2}')
	echo -e "creation date: $creation_date\n"
	echo -e "expire date : $expiration_date\n"
else
	echo -e "${RED}error: please enter vaild domain name.${NC} "
fi

