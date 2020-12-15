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
    cat $OldFile |awk -F" " '{print $2, $1, $3*-1}' > $NewFile # Caris lat, lon, depth
        REGI=`gmt gmtinfo $NewFile -Ie`
        echo "The area setting is: "$REGI
        echo $GRDFile
        gmt nearneighbor $NewFile -G$GRDFile  $REGI -I50e -S0.2m -V # end of making grid
    
    echo 2. Make image of $GRDFile. 
        gmt begin  $OldFile pdf
            gmt grd2cpt $GRDFile -Chaxby -Z  
            gmt grdimage $GRDFile -I+d -B -Y3
            gmt colorbar -D5/-1/10/0.5h -Baf
        gmt end
    rm $NewFile
done;