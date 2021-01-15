#!/bin/bash
#cat *.dat > all.dat
FileExt=*.dat
Number=1
for OldFile in $FileExt;
do
    echo $OldFile
    Na=`basename ${OldFile} .dat`
    NewFile=${Na}_wgs84.dat
    GridInt=100 #(m)

    GRDFile=${Na}_${GridInt}m.grd
    
    echo 1. Make Grid $OldFile to $GRDFile.
    cat $OldFile |awk -F" " '{print $1, $2, $3*-1}' > $NewFile # Caris lat, lon, depth
        REGI=`gmt gmtinfo $NewFile -Ie`
        echo "The area setting is: "$REGI
        echo $GRDFile
        gmt nearneighbor $NewFile -G$GRDFile  $REGI -I${GridInt}e -S0.2m -V # end of making grid
    
    echo 2. Make image of $GRDFile. 
        gmt begin $OldFile pdf
            gmt grd2cpt $GRDFile -Chaxby -Z  
            gmt grdimage $GRDFile -I+d -B -Y3
            gmt basemap -BES+t"${Na}"
            gmt colorbar -Dx5/-1/10/0.5h -Baf
        gmt end
    rm $NewFile
done;