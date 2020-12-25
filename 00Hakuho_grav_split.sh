#!/bin/bash
Data=all.dat

 cat $Data |cut -c 11-14 > yy.tmp
 cat $Data |cut -c 15-17 | sed -e 's/299/1026/g' |sed -e 's/300/1027/g' |sed -e 's/301/1028/g' |sed -e 's/302/1029/g' |sed -e 's/303/1030/g' > dd.tmp
   cat dd.tmp |cut -c 1-2 > dd1.tmp
   cat dd.tmp |cut -c 3-4 > dd2.tmp
 cat $Data |cut -c 18-19 > hh.tmp
 cat $Data |cut -c 20-21 > mm.tmp
 cat $Data |cut -c 22-23 > ss.tmp
 cat $Data |cut -c 25-32 > grav.tmp
 cat $Data |cut -c 33-40 > spring.tmp
paste -d" " yy.tmp dd1.tmp dd2.tmp hh.tmp mm.tmp ss.tmp grav.tmp spring.tmp> result.tmp
cat result.tmp | awk -F" " '{printf "%4d %02d %02d %02d %02d %02d %4.2f %4.2f\n", $1, $2, $3, $4, $5,$6, $7, $8}'> result.dat
rm *.tmp

cat result.dat |awk '{print $1}' >yy.tmp
cat result.dat |awk '{print $2}' >dd1.tmp
cat result.dat |awk '{print $3}' >dd2.tmp
cat result.dat |awk '{print $4}' >hh.tmp
cat result.dat |awk '{print $5}' >mm.tmp
cat result.dat |awk '{print $6}' >ss.tmp
cat result.dat |awk '{print $7}' >grav.tmp
cat result.dat |awk '{print $7}' >spring.tmp
 rm result.dat

paste -d"," yy.tmp dd1.tmp dd2.tmp  > date.tmp
paste -d"," hh.tmp mm.tmp ss.tmp  > time.tmp
paste -d"," date.tmp time.tmp >date_time.tmp
#print(datetime(2018,3,5,0,0).strftime('%s'))

# max=`wc time.tmp |awk '{print $1}'`
# for i in `seq 1 8640`; do
#   #echo $i
#   cat date_time.tmp | sed -n ${i}p |date +%s >> Utime_result.tmp
#  done

# paste -d" " Utime_result.tmp grav.tmp >result.dat
paste -d"," date_time.tmp grav.tmp spring.tmp>result.csv
cat result.csv |awk -F"," '{print $1,$2,$3,$4,$5,$6".000",$7}'|sed 's/ \+/,/g' >grav.csv


rm *.tmp