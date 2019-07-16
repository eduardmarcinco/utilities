#!/bin/bash

usage() {
        echo "Usage: $0 <hostname> <port>"
}

if [ $# -lt 2 ]; then
        echo 1>&2 "$0: not enough arguments"
        usage
        exit 2
elif [ $# -gt 2 ]; then
        echo 1>&2 "$0: too many arguments"
        usage
        exit 2
fi

openssl s_client -showcerts -verify 5 -connect $1:$2 < /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out=a".crt"; print > out}' &&
        for cert in *.crt; do
                index=$(echo $cert | cut -c 1-1);
                newname=$1_$2_$index.pem;
                mv $cert $newname;
        done
