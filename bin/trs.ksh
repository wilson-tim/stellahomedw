#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
sqlplus -s dw/dbp<<Rob_S|read a 
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select 
to_char(trunc(sysdate),'yyyymondd')
from dual;
exit
Rob_S
export today=${a}

echo
cat /home/dw/DWLIVE/load/otop/otop_ls_season.lst|while read season
do
echo
echo TRS numbers in the csc file for ${season} are  `cat /data/tourops/o_csc${today}.${season}|grep "|TRS|"|wc -l`
echo And the corresponding number of records in transport_sale are:-
echo "@/home/dw/bin/trs.sql ${season}"|sqlplus -s dw/dbp
echo
echo "--=<\_/R\_>X<_/S\_/>=--"
done

