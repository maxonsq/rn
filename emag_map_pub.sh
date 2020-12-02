#!/bin/sh

#GMT Setting
	gmt gmtset MAP_FRAME_TYPE plain
	gmt gmtset PS_MEDIA a1
	#
	#REGI=-67:20/-56/-65/-56 #-66/-55/-64/-57 #along ar
	REGI=-68/-54/-63:50/-58:30
	NAME=emag_vs_MB
	#
	GRDO=EMAG2_V2.grd #mag
	BG_GRD=ETOPO1_Ice_g_gmt4.grd #bathy
	#
	PS=${NAME}.ps
	PROJ=M16
	Bf=WeNs  #Frame parameters
	Bx=a3f5m  #Axes parameters
	By=a1f5m  #Axes parameters
	CPTO=haxby #base colour palette
	RESO=f 
	#
	CONT=250 #50
	CONT2=1000
	LIMIT=-200/200 #mag
   	LIMIT2=-7000/250 #bathy
	#
	CPTO=EMAG2_nise.cpt

#Make colour palette
	gmt makecpt -C$CPTO -T${LIMIT}/10 -Z > temp2.cpt
#Draw map; Global Back ground
	gmt grdimage $GRDO -R$REGI -J$PROJ -Ctemp2.cpt -P -K -Y3 -V -U$0　>$PS
   	gmt grdcontour $BG_GRD -R$REGI -J$PROJ -C$CONT -W0.1,50/50/50 -L$LIMIT2 -K -O -V >>$PS
	gmt grdcontour $BG_GRD -R$REGI -J$PROJ -C$CONT2 -W0.1black -L$LIMIT2 -K -O -V >>$PS	
    gmt psscale -D12/-1/5/0.5h -Ba100f100g50:"Total_intensity_anomaly[nT]": -Ctemp2.cpt  -P -K -O -V >>$PS


#Pswiggle 1
	FileExt=/lines_coeff1_area/*.wiggle
	Number=1
	for OldFile in $FileExt;
	do
	echo $OldFile
		cat $OldFile |awk '{print $3, $2, $7}' |awk 'NR%100==0' >temp0.mag
		gmt pswiggle temp0.mag -R$REGI -J$PROJ -Wthinnest,black -Gblack+p -Tthinnest -Z2000 -K -O >>$PS   
		Number=$((Number+1))
	done;
	rm temp0.mag



#Plot magnetic boundary1
	FileExt=/lines_coeff1_area/*.peak
	Number=1
	#plot deviation
	for OldFile in $FileExt;
	do
	echo "Draw Standard deviation at " $OldFile
		cat $OldFile |sed -e '1d'|awk '$10 >= 0 && $10 <=0.33 {print $3,$2,180-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -Gblack -R$REGI -J$PROJ -K -O -V>>$PS

		cat $OldFile |sed -e '1d'|awk '$10 > 0.33 && $10 <=0.66 {print $3,$2,180-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -G200 -R$REGI -J$PROJ -K -O -V>>$PS

		cat $OldFile |sed -e '1d'|awk '$10 > 0.66 && $10 <=1 {print $3,$2,180-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -G130 -R$REGI -J$PROJ -K -O -V>>$PS

		cat $OldFile |sed -e '1d'|awk '$10 >1 {print $3,$2,180-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -Gwhite -R$REGI -J$PROJ -K -O -V>>$PS

	done;
	#plot boundary
	for OldFile in $FileExt;
	do
	echo "Draw Magnetic boundary at " $OldFile
		cat $OldFile |sed -e '1d'|awk '$11 >= 0 && $11 <=50 {print $3,$2,90-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -Gblue  -R$REGI -J$PROJ -K -O -V >>$PS

		cat $OldFile |sed -e '1d'|awk '$11 > 50 && $11 <=100 {print $3,$2,90-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -Ggreen -R$REGI -J$PROJ -K -O -V >>$PS

		cat $OldFile |sed -e '1d'|awk '$11 > 100 && $11 <=150 {print $3,$2,90-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -Gyellow -R$REGI -J$PROJ -K -O -V >>$PS

		cat $OldFile |sed -e '1d'|awk '$11 > 150 && $11 <=200 {print $3,$2,90-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -Gorange -R$REGI -J$PROJ -K -O -V >>$PS

		cat $OldFile |sed -e '1d'|awk '$11 >200 {print $3,$2,90-$14,15,1.5}' >temp0.mag
		gmt psxy temp0.mag -SJ -Gred  -R$REGI -J$PROJ -K -O -V >>$PS
	done;
	rm temp0.mag

#End of GMT
	gmt psbasemap -R$REGI -J$PROJ -B"${Bf}" -Bx"${Bx}" -By"${By}" -O -V  >>$PS #-Lf-31/-61.5/-61.5/100+l
#Convert
	gmt psconvert $PS -A -Tf -P
	gmt psconvert $PS -A -Tj