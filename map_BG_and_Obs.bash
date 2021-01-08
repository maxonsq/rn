#!/bin/sh
#SETTING START##########################
#Grid setting
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset PS_MEDIA a2
#
REGI=140:20/145:30/37/41
#143.1048535/144.3953097/37.7966131/38.2196039
#138.9673797/139.9740202/41.4240309/42.1399122
NAME=kh-20-10_test10
#
BG_GRD=/mnt/d/gmt/01GRD_dir/Bathy/Global/ETOPO1_Ice_g_gmt4.grd
GRDO=kh-20-10_test10.xyz.grd # 0817_cc_light.grd #
Gra_GRD=/mnt/d/gmt/01GRD_dir/Geophys_data/ba2300_gsj_ver3_500m.grd

#出力ファイル名
PS=${NAME}.ps
#psfile=${NAME}_slope.ps
#投影法と横幅
PROJ=M16  #L${REGI}/16  #Q-60/-26:25/16
IDOU=-X12
#外枠の設定fは白黒の間隔,aは数字を入れる間隔,gはグリッド
 #M16                                # map projection and scale
Bf=WeNs  ### Frame parameters
# Bx=f1a1  ### Axes parameters
# By=f15ma20m ## Axes parameters
Bx=a1f1g10m  ### Axes parameters
By=a1f1g10m  ### Axes parameters
#使用するカラーパレット
CPTO=haxby
CPT=temp.cpt
#海岸線解像度
RESO=f
#cont:コンターの間隔,ｍ単位 anot:等深線に入れるメモリ limit:コンターを作る高さのエリア指定
CONT=100 #50
CONT2=500
#ANOT=2000t
LIMIT=-8000/0
#-2176.67260742 z_max: -2145.57983398
INT=temp.int
#LIMIT=22000/46000
#光の当て具合
LIGHT=45/45
#INT=worldmap.int
# TRACK=all_tracks.txt
#
#gmt makecpt -C$CPTO -T${LIMIT}/500 -Z > $CPT #-T${LIMIT}/500 #Bx z_min:  8621.68066406 z_max: 19802.0566406
#
GRD=temp.grd
gmt grdcut $BG_GRD -R$REGI -G$GRD -V
gmt grdinfo $GRD
gmt grdgradient $GRD -A$LIGHT -G$INT -Ne0.8 -V 
#
gmt makecpt -Cgray -T${LIMIT}/250 -Z > temp2.cpt
gmt grdimage $GRD -R$REGI -I$INT -J$PROJ -Ctemp2.cpt -P -K -Y3 -V >$PS #
gmt grdcontour $GRD -R$REGI -J$PROJ -C$CONT -W0.1,50/50/50 -L$LIMIT -K -O -V >>$PS
gmt grdcontour $GRD -R$REGI -J$PROJ -C$CONT2 -W0.1black -L$LIMIT -K -O -V >>$PS
#
gmt grdcut $GRDO -R$REGI -G$GRD -V
gmt grdinfo $GRD
gmt grdgradient $GRD -A$LIGHT -G$INT -Ne0.8 -V
#
gmt makecpt -Chaxby -T${LIMIT}/250 -Z > temp2.cpt
gmt grdimage $GRD -R$REGI -I$INT -J$PROJ -Ctemp2.cpt -P -K -O -Q -V >>$PS #-U$0
gmt grdcontour $GRD -R$REGI -J$PROJ -C$CONT -W0.1,50/50/50 -L$LIMIT -K -O -V >>$PS
gmt grdcontour $GRD -R$REGI -J$PROJ -C$CONT2 -W0.1black -L$LIMIT -K -O -V >>$PS
#gmt psxy points.txt -R -SC0.1 -Gred -JM -V -O -K >> $PS
#gmt psxy track.dat -R -W0.1 -JM -V -O -K >> $PS
#
gmt pscoast -R$REGI -J$PROJ -D$RESO -Ggray -W0.1  -K -O -V >>$PS #-G233/185/110
gmt psscale -D5/-1/8/0.5h -Ba2000f1000g500:"Depth[m]": -Ctemp2.cpt  -P -K -O -V >>$PS
gmt psbasemap -R$REGI -J$PROJ -B"${Bf}" -Bx"${Bx}" -By"${By}" -K -O -V  >>$PS #-Lf-31/-61.5/-61.5/100+l
#
# WPDAT=track_KH19-6_leg4_fj.txt
# gmt psxy $WPDAT -W1,yellow -R -J -K -O -V >>$PS
# gmt psxy $WPDAT -Gyellow -Sc0.1 -R -J -K -O >>$PS
# #
#  WPDAT=track_KH19-6_leg4_vulcan3.txt
#  gmt psxy $WPDAT -W1,black -R -J -K -O -V >>$PS
#  gmt psxy $WPDAT -Gblack -Sc0.1 -R -J -K -O >>$PS
#
# cat 01041639.anm_cc_igrf |awk '{print $8, $7, $14}' >temp0.mag
# gmt pswiggle temp0.mag -R$REGI -J$PROJ -Wthinnest,white -Gred -Tthinnest -Z1000 -K -O -V -Sx1/1.5/200nT >>$PS
# #
# cat 01070506.anm_cc_igrf |awk '{print $8, $7, $14}' >temp0.mag
# gmt pswiggle temp0.mag -R$REGI -J$PROJ -Wthinnest,white -Gred -Tthinnest -Z1000 -K -O -V -Sx1/1.5/200nT >>$PS
# #EEZ
#gmt psxy eez_boundaries.gmt -Wthinnest,red -R$REGI -J$PROJ -K -O -V >>$PS
#gmt psxy all_track_W.txt -W1,yellow -R$REGI -J$PROJ -K -O -V >>$PS
#
# calculate azimth / slope
# azimfile=area_azim.grd                  # output azimuth file (degree)
# slopefile=area_slope.grd                   # output slope in azimthal direction (degree)
# cptfile_slope=slope.cpt
# gmt grdcut ETOPO1_Ice_g_gmt4.grd -R$REGI -G$GRD -V
# #gmt grdinfo $GRD
# gmt grdgradient $GRD -Stmpslope.grd -D -M -G$azimfile -V
# gmt grdmath tmpslope.grd ATAN PI DIV 180 MUL = $slopefile
# gmt grdimage $slopefile -R$REGI -J$PROJ -C$cptfile_slope -K -O $IDOU >> $PS
# gmt psxy points.txt -R -SC0.1 -Gred -JM -V -O -K >> $PS
# gmt psscale -D5/-1/8/0.5h -B10:"Slope[deg]": -C$cptfile_slope -K -O  >> $PS
# gmt psbasemap -R$REGI -J$PROJ -B"${Bf}" -Bx"${Bx}" -By"${By}" -K -O -V  >> $PS #-Lf-31/-61.5/-61.5/100+l
# #
# GRD=temp3.grd
# gmt grdcut $Gra_GRD -R$REGI -G$GRD -V
# gmt makecpt -Cpolar -T-250/250/10 -Z > temp3.cpt
# gmt grdimage  $GRD -R$REGI -J$PROJ -Ctemp3.cpt -K -O $IDOU >> $PS
# gmt psxy points.txt -R -SC0.1 -Gred -JM -V -O -K >> $PS
# gmt psscale -D5/-1/8/0.5h -B50:"ba2300[mGal]": -Ctemp3.cpt -K -O  >> $PS
gmt psbasemap -R$REGI -J$PROJ -B"${Bf}" -Bx"${Bx}" -By"${By}" -O -V  >> $PS #-Lf-31/-61.5/-61.5/100+l
#gmt psxy eez_boundaries.gmt -W2,yellow -R$REGI -J$PROJ  -O -V >>$PS
# #
#evince $PS &
gmt psconvert $PS -A -Tf -P
gmt psconvert $PS -A -Tj