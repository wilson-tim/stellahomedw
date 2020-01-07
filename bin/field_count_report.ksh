#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
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


#!/bin/ksh
#Keep the main season up to date
#Don't run this on Saturdays due to .otop files
load_path="/home/dw/DWLIVE/load/otop/"
rob_path="/home/dw/rob/"
data_path="/data/tourops/"
>${rob_path}f1.lis
cat ${rob_path}lookup.dat|while read a b c
do
echo "Group ${a} file ${b}  has `head -n1 ${data_path}o_${b}*.s05|tr -cd \||wc -c`   versus " >>${rob_path}f1.lis
done

>${rob_path}f2.lis
cat ${rob_path}lookup.dat|while read a b c
do
sqlplus  -s dw/dbp<<Rob_S|read j
set linesize 200
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select count(column_name)||' in ${c}    ---   excluding dud and span' from all_tab_columns 
where table_name=upper('${c}') 
and column_name!='SPAN' 
and column_name!='DETAILS_UPDATED_DATE'
and owner='DW'
;
exit
Rob_S
echo ${j}>>${rob_path}f2.lis
done

paste ${rob_path}f1.lis ${rob_path}f2.lis >${rob_path}field_count_report.lis
rm f1.lis f2.lis
cat ${rob_path}field_count_report.lis

