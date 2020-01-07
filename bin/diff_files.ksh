#!/bin/ksh
#This is diff_files.ksh
load_path="/home/dw/DWLIVE/load/otop/"
cat ${load_path}otop_l_diffgrps.lst|while read x
do
cat ${load_path}otop_l_${x}.lst|while read y
do
echo ${y}
done
done
