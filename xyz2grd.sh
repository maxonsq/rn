#!/bin/bash
#cat *.dat > all.dat
FileExt=*.xyz
Number=1
for OldFile in $FileExt;
do
    echo $OldFile
    NewFile=${OldFile}_wgs84.dat 
    GRDFile=${OldFile}.grd
    
    echo 1. Make Grid $OldFile to $GRDFile.
    #cat $OldFile |awk '{print $7, $6, $8*-1}' > $NewFile # lat, lon, depth
    cat $OldFile |gmt mapproject -Ju+54/1:1 -C -I -F > $NewFile # lat, lon, depth
        REGI=`gmt gmtinfo $NewFile -Ie`
        echo "The area setting is: "$REGI
        gmt nearneighbor $NewFile -G$GRDFile  $REGI -I10e -S0.02m -V # end of making grid
    
    echo 2. Make image of $GRDFile. 
        gmt begin  $OldFile pdf
            gmt grd2cpt $GRDFile -Chaxby -Z  
            gmt grdimage $GRDFile -I+d -B -Y3
            gmt colorbar -D5/-1/10/0.5h -Baf
        gmt end
    rm $NewFile
done;