#!/bin/bash
FileExt=*.xyz
Number=1
for OldFile in $FileExt;
do
    echo $OldFile
    NewFile=${OldFile}.txt 
    GRDFile=${OldFile}.grd
    echo $NewFile
    echo Make Grid $OldFile to $GRDFile.
    #cat $OldFile |awk '{print $6, $7, $8*-1}' > $NewFile # lat, lon, depth
    cat $OldFile |awk '{printf "%.6f %.6f %.3f \n", $2, $1, $3*-1}' > $NewFile # lat, lon, depth
    head $NewFile
    # cat $OldFile >$NewFile
        REGI=`gmt gmtinfo $NewFile -I0.01`
        echo "The area setting is: "$REGI
        gmt nearneighbor $NewFile -G$GRDFile  $REGI -I50e -S150e -V # end of making grid
    echo making $GRDFile is finish. now start imaging. 
        gmt begin  $OldFile pdf
            gmt grd2cpt $GRDFile -Chaxby -Z  
            gmt grdimage $GRDFile -I+d -B -Y3
            gmt colorbar -D5/-1/10/0.5h -Baf
        gmt end
    rm $NewFile
done;