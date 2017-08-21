#!/bin/bash
Index=($(/opt/dell/srvadmin/bin/omreport chassis memory |grep "Index" |cut -d : -f 2 |xargs))
Indexnum=${#Index[@]}
echo -e "{
    \"data\":[\c"
for i in ${Index[@]}
do
echo -e "
    {\c"
echo -e "
        \"{#MEMINDEX}\":\"$i\"},\c"
done
echo -e "
        {\c"
echo -e "
        \"{#INDEXNUM}\":\"$Indexnum\"}]}\c"
