#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
log_path="/home/dw/DWLIVE/logs/otop/"
data_path="/data/tourops/"
#--=<\_/R\_>X<_/S\_/>=--
sqlplus -s dw/dbp<<Rob_S|read x
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select to_char(trunc(sysdate),'yyyymondd') from dual;
exit
Rob_S
export today=${x}
#--=<\_/R\_>X<_/S\_/>=--
rm ${log_path}empty_load_tables.lst
#Initialise
>${log_path}empty_load_tables.lst
#
find ${log_path} -name "o_???_log${today}.???"|sort|while read x
do
grep -li " 0 rows successfully loaded" ${x}|cut -b27,28,29,30,31,36,37,38,39,40,41,42,43,44,45,46,47,48>>${log_path}empty_load_tables.lst
done
#
echo "The files below loaded nothing to their corresponding load tables."
echo "if any of these files are NOT ALSO EMPTY (indicated by the leftmost figure below)"
echo "the corresponding sqlload has failed."
cat ${log_path}empty_load_tables.lst|while read x
do
wc -l ${data_path}${x}*|grep -v total|grep -v otop
done
