#!/bin/bash
#after format_stcm_v2.sh
FileExt=*.sfg.txt # #*.sfg.txt
Number=1
GRD=/mnt/d/gmt/01GRD_dir/Bathy/Global/ETOPO1_Ice_g_gmt4.grd
#kh19-1.xyz.grd
#

for OldFile in $FileExt;
do
    echo $OldFile
    NewFile=${OldFile}_stcm.dat #$(printf KR19_segy_%04d.sgy $Number)
    cat ${OldFile} |awk '{print $8,$9}' >temp1_latlon.dat
    gmt grdtrack temp1_latlon.dat -G$GRD -N>temp2_latlondepth.dat
    cat temp2_latlondepth.dat | awk '{print $3}'|sed 's_NaN_-9999_g'> temp3_depthnegative.dat
    cat temp3_depthnegative.dat |awk '{print $1*-1}'|awk '{printf "%04d\n",$1}'>temp4_depthpositive.dat
    cat $OldFile |sed 's_ _\t_g' >temp5_tabolds.dat
    paste -d"\t" temp4_depthpositive.dat  temp5_tabolds.dat >temp6_pasted.dat
    cat temp6_pasted.dat | awk -F"\t" '{print $3+2000,$4,$5,$6,$7,$8,$10,$9,$1,9999,9999,$11,$12,$13,$14,$15,$16}'> $NewFile
    Number=$((Number+1))
    wc -l temp*.dat $NewFile
done;
#rm temp*.dat