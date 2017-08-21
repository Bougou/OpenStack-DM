#!/bin/bash
Index=($(/opt/MegaRAID/MegaCli/MegaCli64 -PDList -a0 |egrep "Device Id" |cut -d " " -f 3 |xargs))
Indexnum=${#Index[@]}
echo -e "{
    \"data\":[\c"
for i in ${Index[@]}
do
echo -e "
    {\c"
echo -e "
        \"{#PDINDEX}\":\"$i\"},\c"
done
echo -e "
    {\c"
echo -e "
        \"{#PDNUM}\":\"$Indexnum\"}]}"
        