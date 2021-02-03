#!/bin/bash
#after format_stcm_v2.sh
FileExt=*.dat # #*.sfg.txt
Number=1
#kh19-1.xyz.grd
#
ls *.dat

for OldFile in $FileExt;
do
    echo "->" $OldFile
    NewFile=${OldFile}.matd #$(printf KR19_segy_%04d.sgy $Number)
    cat $OldFile | sed "s_/_ _g" | sed "s/:/ /g" | sed "s/,/ /g" | sed "s/+//g"  | sed -e '1d'|tr -d $>temp
    cat temp |awk -F" " '{print $1,$2,$3,$4,$5,$6,$7}' > $NewFile
done;