#!/bin/bash
apt install bind9 -y
echo "; Created by terraform "> /etc/bind/rebrainme.com
echo '$TTL 86400' >> /etc/bind/rebrainme.com
echo ";"  >> /etc/bind/rebrainme.com
echo "@ IN SOA rebrainme.com. root.rebrainme.com. (1 604800 86400 2419200 86400 )" >> /etc/bind/rebrainme.com
echo ";" >> /etc/bind/rebrainme.com
echo "@ IN NS $HOSTNAME" >> /etc/bind/rebrainme.com
echo "$HOSTNAME IN A $1" >> /etc/bind/rebrainme.com
echo " " >> /etc/bind/rebrainme.com
echo "//Adding by terraform ">> /etc/bind/named.conf.local
echo 'zone "rebrainme.com" { type master; file "/etc/bind/rebrainme.com"; }; ' >> /etc/bind/named.conf.local
systemctl restart bind9.service