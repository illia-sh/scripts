#!/bin/bash
#TP_Link Authorization get external_ip 

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters";
    echo "Usage: $0 ROUTER_IP USERNAME PASSWORD";
    exit;
fi
 
IP="$1";
USERNAME="$2";
PASSWORD="$3";
 
MAX_TRIES=1; # maximum number of reboot attempts
SYSLOG_TAG="get_external-IP"
 
# From https://stackoverflow.com/questions/296536/urlencode-from-a-bash-script/10660730#10660730
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
 
  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}
 
PASSWORD_MD5=`echo -n $PASSWORD | md5sum | cut -d " " -f 1`;
COOKIE_B64_PART=`echo -n $USERNAME":"$(echo -n $PASSWORD_MD5)|base64`;
COOKIEVAL_UNENCODED=`echo -n "Basic $COOKIE_B64_PART"`;
COOKIEVAL=`rawurlencode "$COOKIEVAL_UNENCODED"`
 
GET_KEY_URL=`echo "http://$IP/userRpm/LoginRpm.htm?Save=Save"`
 
 
# If the reboot sequence fails, try again $MAX_TRIES times
for i in $(seq $MAX_TRIES)
do
 
  RESPONSE=`curl -s --cookie "Authorization=$COOKIEVAL" $GET_KEY_URL`;
  KEY=`echo $RESPONSE |  head -n 1 | cut -d '/' -f 4` # extract key from post-login-page
 
  sleep 1;
 
  STATUS_URL="http://$IP/$KEY/userRpm/StatusRpm.htm";
  MAIN_URL="http://"$IP"/"$KEY"/userRpm/Index.htm";
  
  FINAL_RESPONSE=`curl -s --cookie "Authorization=$COOKIEVAL" --referer $MAIN_URL $STATUS_URL`;

  reg_match=`echo $FINAL_RESPONSE | egrep -o "134.[0-9]*\.[0-9]*\.[0-9]{1,3}" | head -1`;

  MATCHES=`echo $reg_match | wc -l`
  
  if [ $MATCHES -gt 0 ]; then
    # Success!
    break
  else
    echo "Failed on try $i..."
    sleep 1;
  fi
done
 
if [ $MATCHES -gt 0 ]; then
  SUCCESS_TEXT="Successfully get ip address  $reg_match.";
  echo $SUCCESS_TEXT;
  logger -t $SYSLOG_TAG $SUCCESS_TEXT;
else
  FAILURE_TEXT="Failed to get ext-IP $reg_match on $IP.";
  echo $FAILURE_TEXT;
  logger -t $SYSLOG_TAG $FAILURE_TEXT;
 
  exit 1;
fi
