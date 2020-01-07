#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
#This is glue_otop.ksh:    Rob_S
#For sticking .otop on the end of the diffed files, ready for use on nights 
#following a full load. 

ld_path="/home/dw/DWLIVE/load/otop/"
dt_path="/data/tourops/"

#--=<\_/R\_>X<_/S\_/>=--Usual trick to get Oracle values out to the shell. 
#--=<\_/R\_>X<_/S\_/>=--Today's date in this case.
sqlplus -s dw/dbp<<Rob_S|read a
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select to_char(trunc(sysdate),'yyyymondd') from dual;
exit
Rob_S
export d=${a}
#--=<\_/R\_>X<_/S\_/>=-------------------------------------

cat ${ld_path}otop_ls_season.lst|while read x
do
cat ${ld_path}otop_l_diffgrps.lst|while read y
do
cat ${ld_path}otop_l_${y}.lst|while read z
do

if [[ -a ${dt_path}o_${z}${d}.${x} && ! -a ${dt_path}o_${z}${d}.${x}.otop ]]
then
mv ${dt_path}o_${z}${d}.${x} ${dt_path}o_${z}${d}.${x}.otop
fi

done
done
done
