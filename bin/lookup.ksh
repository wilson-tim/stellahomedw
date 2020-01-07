#!/bin/ksh
#This gets a useful lookup_up list of abbrevs and load table names via 
#the group lst files and the corresponding sqlldr control scripts
#
load_path="/home/dw/DWLIVE/load/otop/"
rob_path="/home/dw/rob/"
>${rob_path}lookup.dat1
cat ${load_path}xmis.lst|while read x
do 
cat ${load_path}otop_l_${x}.lst|while read y
do
echo ${x} ${y} `cat ${load_path}o_${y}.ctl|grep INTO`>>${rob_path}lookup.dat1
done
done
>${rob_path}lookup.dat
cat ${rob_path}lookup.dat1|while read a b dummy1 dummy2 c
do 
echo ${a} ${b} ${c}|grep -v "tex">>${rob_path}lookup.dat
done
rm ${rob_path}lookup.dat1
cat ${rob_path}lookup.dat
