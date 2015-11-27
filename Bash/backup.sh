#!/bin/sh
lockfile="/tmp/solr_backup.lock"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
trap "rm -f $lockfile && exit" SIGINT SIGTERM
DATE=`date +%Y_%m_%d-%H_%M_%S`
brands=( nvbfrog nvnfrog tcbefrog vufrog uk )
Spath="/solrdata"
BKpath="/mnt/backupserver/SOLR_INDEX"
recipients="test@test.com"

check_lock()
{
if [ -f "$lockfile" ]; then
  email "$lockfile exist" 1 && exit 1
 else
  echo $$ > $lockfile
fi
}

check_brand()
{
for i in  "${brands[@]}" ; do
  if [ -d $Spath/storage/$i ]; then
   brandname=`echo "$Spath/storage/$i" | awk -F "/" '{print $4}'`
  fi
done
}

set_path()
{
tmp="/data/backups/shared-$brandname-$DATE.tar.gz"
target="$BKpath/shared-$brandname-$DATE.tar.gz"
}

check_free_space()
{
FREE=`df -m |  grep "backupserver" | awk '{ print $3 }'`
if [[ $FREE -lt 102400 ]]; then
  email "Less than 100GB free space left, stopping." 1 && rm -f $lockfile && exit 1
fi
}

tarring()
{
set_path
check_free_space
start_time=`date +%H:%M:%S`;/bin/tar czf $tmp -C $Spath/ shared-$brandname && mv $tmp $target;end_time=`date +%H:%M:%S`
find $BKpath -type f -name "shared-$brandname-*.tar.gz"  -mtime +2 -exec rm {} \;
SIZE=`du -sh $target| awk '{print $1}'`
DIRSIZE=`du -sh $BKpath | awk '{print $1}'`
}

email()
{
if [[ $2 == "1" ]]; then
     echo -e "$DIR/$0 \n$DATE \n$1" | mutt -s "Solr-$brandname error backup" -- $recipients
 else
     echo -e "$DIR/$0 \n$DATE \nStarted at $start_time \nfinished at $end_time \n$target size is : $SIZE \nALL backups size in $BKpath :$DIRSIZE" | mutt -s "Solr-$brandname backup" -- $recipients
fi
}

##################################
check_brand
check_lock
tarring
email
rm -f $lockfile

