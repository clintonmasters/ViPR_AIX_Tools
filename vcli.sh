#!/bin/sh -e
# ViPR demo script May 5,2015
# Written for lightfoot ViPR 2.2 --cbm

# Set the ViPR IP
ViPR_IP=192.168.10.50

# Cookie File
COOKIE=~/vcookie

#check usage
if [ $# -ne 1 ]; then
	echo 1>&2 "Usage $0 lab1 | lab2 | lab1undo"
	exit 127
fi

case "$1" in

  lab1)
  
    echo "\nAuthenticating . . ."
    curl -L --location-trusted \
		-k https://$ViPR_IP:4443/login?using-cookies=true \
		-u "root:ChangeMe1!" \
		-c $COOKIE -s \
		| xmllint --format -

	echo "\n\nGetting Tenant Info"

	curl -k https://$ViPR_IP:4443/tenant -b $COOKIE -s \
		| xmllint --format -
	 
	;;

  lab2)
  

	echo "\nGetting Tenant Info"

	TENANT=`curl -k https://$ViPR_IP:4443/tenant -b $COOKIE -s \
		| perl -ne 'm!TenantOrg:([0-9a-f-]+):!; print $1' `

	echo "\n\nMy Tenant is ${TENANT}."
  	echo "Register new Server\n"

	curl -k https://$ViPR_IP:4443/compute/hosts -b $COOKIE \
		-H "Content-Type: application/xml" -s \
		--data "@-" <<EOF | xmllint --format -
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<host_create>
     <type>AIX</type>
     <host_name>192.168.0.10</host_name>
     <name>host1aix</name>
     <port_number>22</port_number>
     <user_name>root</user_name>
     <password>pancake</password>
     <use_ssl>false</use_ssl>
     <tenant>urn:storageos:TenantOrg:$TENANT:global</tenant>
</host_create>
EOF
	echo "\n"
	;;
  
esac
