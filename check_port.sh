#!/bin/bash
IPADDR=$1
PORT=$2

if [ $# -ne 2 ]; then
    echo "Usage:"
    echo "  $0 [IPADDR|DOMAIN] [PORT]"
    echo ""
    echo "Examples:"
    echo "  $0 localhost 80"
    echo "  $0 192.168.1.1 80"
    exit
fi

result=`echo -e "\n" | telnet $IPADDR $PORT 2>/dev/null | grep Connected | wc -l`

if [ $result -eq 1 ]; then
      echo "Network is Open."
else
      echo "Network is Closed."
fi
