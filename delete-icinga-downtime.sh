#!/bin/bash

server=$1

if [ -z "$server" ]; then
        echo "Server is not filled!"
        exit 1
fi

ssh root@XXX "curl -6 -k -s -u root:XXX -H 'Accept: application/json' -X POST 'https://XXX:5665/v1/actions/remove-downtime?filter=host.name==%22'$server'%22&type=Host'" > /dev/null
ssh root@XXX "curl -6 -k -s -u root:XXX -H 'Accept: application/json' -X POST 'https://XXX:5665/v1/actions/remove-downtime?filter=host.name==%22'$server'%22&type=Service'" > /dev/null
