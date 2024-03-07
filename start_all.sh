#!/bin/bash

/huproxy -listen 127.0.0.1:8086 &

mkdir /run/sshd
/usr/sbin/sshd -D &

# local users for ssh
while read line
do
  # adduser  -b users.proxy $line
  username="$(echo "$line" | awk '{print $1}')"
  password_plain="$(echo "$line" | awk '{print $2}')"
  password_hash="$(openssl passwd -6 -salt xyz "$password_plain")"
  useradd --create-home --user-group --password "$password_hash" "$username"
done < /ssh_users.plain

nginx -g 'daemon off;'
