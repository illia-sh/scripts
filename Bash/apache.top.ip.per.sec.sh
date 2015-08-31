#!/bin/sh
#URL=("GET /content-api/")
function ip-where { curl -s ipinfo.io/$i | grep -i country | awk -F '"' '{print $4}';}
time=$(date +"%d/%b/%Y" -d '1 days ago')
log="/etc/httpd/logs/access_*.log"
IP=$(grep $time $log | grep "$URL"| awk '{print $1}' | sort | uniq -c | sort -rnk1 | head -10 | awk '{print $2}')
for i in $IP ; do geo=$(ip-where $i) && count=$(grep $time $log | grep "$URL" |grep "$i" | awk {'print $4'} | sort | uniq -c | sort -rnk1 | head -1 | awk '{print $1,$2}' | sed s"/\[//"g ) && echo "IP:$i | req/sec= $count | country:$geo" ; done | sort -rnk4

