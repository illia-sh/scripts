#!/bin/bash

sincetime() {
init=`stat -t /proc/$1 | awk '{print $14}'`
curr=`date +%s`
seconds=`echo $curr - $init| bc`
name=`cat /proc/$1/cmdline`
echo $name $seconds
}

pidlist=`ps ax | grep -i -E $1 | grep -v grep | grep -v 'bash' | awk '{print $1}' | grep -v PID | xargs echo`
for pid in $pidlist; do
    sincetime $pid
done
