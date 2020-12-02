#!/bin/bash
FileExt=*.dat
Number=1
#
touch temp_all
for OldFile in $FileExt;
do
echo $OldFile
    cat $OldFile | sed "s_/_ _g" | sed "s/:/ /g" | sed "s/,/ /g" | sed "s/+//g"  | sed -e '1d' >temp
    cat temp | awk -F" " 'BEGIN {OFS="\t"} {print $1,$2, $3, $4, $5, $6, $7, $8, $10, 9999, 9999, $17, $18, $19, $16, $13, $14}' >>temp_all
    Number=$((Number+1))
    rm temp
done;

cat temp_all > all_stcm.dat
rm temp_all