 #!/bin/sh

DAT=temp.txt
cat kml_dat.txt |sed -e '1d' > $DAT
max=`cat ${DAT}| wc -l`

#for i in {1..${max}}; do
i=1
for i in `seq ${max}`
do

#loop 1
#i=1
NAME=`sed -n ${i}p ${DAT} |awk '{print $4}'`
DES=`sed -n ${i}p ${DAT} |awk 'BEGIN{OFS=","} {print $1, $2,$3 "m" ,$5, $6}'` #1
LON=`sed -n ${i}p ${DAT} |awk '{print $7}'`
LAT=`sed -n ${i}p ${DAT} |awk '{print $8}'` 
file=${NAME}.kml

echo $i $NAME
echo '<?xml version="1.0" encoding="UTF-8"?>' >$file
echo '<kml xmlns="http://www.opengis.net/kml/2.2"> <Placemark>' >>$file
echo '<Style id="sn_blue-dot_copy3">' >>$file
echo '<IconStyle>' >>$file
echo '<Icon>' >>$file
echo '<href>http://www.google.com/intl/en_us/mapfiles/ms/icons/blue-dot.png</href>' >>$file
echo '</Icon>' >>$file
echo '</IconStyle>' >>$file
echo '</Style>' >>$file
echo "<name>${NAME}</name>" >>$file
echo "<description>${DES}</description>" >>$file
echo '<Point>' >>$file
echo "<coordinates>${LON},${LAT},0</coordinates>" >>$file
echo " </Point>" >>$file
echo " </Placemark> </kml>" >>$file

done;
rm ${DAT}