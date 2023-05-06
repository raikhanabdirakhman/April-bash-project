#!/bin/bash

for ip in $@          # $@ = all IPs inputed, eg bash copy.sh 134.13.13.13  156.134.45.56
do
scp function.sh root@$ip:
ssh -t root@$ip bash function.sh
done
