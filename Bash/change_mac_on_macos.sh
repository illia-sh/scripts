#!/bin/bash
NEWMAC=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//') 
sudo ifconfig $1 ether $NEWMAC 

