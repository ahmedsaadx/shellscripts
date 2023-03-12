#!/bin/bash

# Get the new user's name
read -p "enter user name: " username

# Prompt for shell access
read -p "should this user have shell access? (y/n): " shell_access
# password
read -s -p  "enter user  password: "  pass 

if [[ $shell_access == "y" ]]; then
  shell="/bin/bash"
else
  shell="/bin/false"
fi

# Create the new user
sudo useradd -m -s $shell $username

# Set a password for the new user without interaction
echo "$username:$pass" | sudo chpasswd

echo "User $username created with shell access set to $shell."


