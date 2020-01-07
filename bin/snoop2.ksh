#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
#
#This is snoop.ksh
#
export source=`hostname`
#Getting day,date,time stuff from Oracle
sqlplus -s dw/dbp<<Rob_S|read a b
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select 
decode(to_char(sysdate,'dy'),'fri','wend','wday'),
to_char(trunc(sysdate)+1,'yyyymondd')
from dual;
exit
Rob_S
export wend_wday=${a}
export tomorrow_1=${b}

echo
echo "THIS EMAIL IS COMING FROM THE "${source}" BOX"
echo "This (the o/p of snoop) shows the integration setup for TONIGHT"
echo "following season and group switching at 23:45."
echo "If integrating right now - use snoop_immediate instead of snoop"
echo
echo "Seasons being integrated are:-"
cat /home/dw/DWLIVE/load/otop/otop_ls_season_${wend_wday}.lst
echo "__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__"
echo
echo "For current seasons groups to be integrated should include:-"
echo "mer,spk, cor, mkt, gen, acc, trs, shr, gsh, int:  with one of them including shd"
echo "For older seasons we are only integrating on Saturday morning"
echo "------------------------------------"
echo ".  .  .  and tomorrow is a ${wend_wday} so the groups per season are:-" 
cat /home/dw/DWLIVE/load/otop/otop_ls_season_${wend_wday}.lst|while read season
do
echo
echo "__/\__/\__/\__${season}__/\__/\__/\__"
cat "/home/dw/DWLIVE/load/otop/otop_ls_abbrev_${wend_wday}.${season}"
done
echo
echo "Normally scheduled for half past one. Appearing as  30  01  *  *  * - "
echo " -  the relevant line(s) from crontab are:-"
crontab -l|grep "dw_control"|grep -v "#"
echo
echo
echo "There should be nothing between the following RS lines."
echo "If there is - integration is currently running and will need investigation and stopping."
echo
echo "--___/R\_*|*_/S\___--"
ps -ef|grep "dw_control"|grep -v "grep"
echo "--___/R\_*|*_/S\___--"
echo
echo "__/\__/\__/\__/\__"
echo 
echo "Below shows where we are integrating from: Gemini Live (cray) or Gemini Test (10.20.0.29)"
echo "As targeted in the otop_k_ini shell script."
echo
export load_path="/home/dw/DWLIVE/load/otop/"
#
> ${load_path}dummy_otop_k_ini.ksh
#
grep "open"  ${load_path}*otop_k_ini.ksh>${load_path}x.lis
rm ${load_path}dummy_*
#
cat ${load_path}x.lis|grep -v "#"|grep -v "aptostest"
#
rm ${load_path}x.lis
echo
echo "__/\__/\__/\__"
echo
echo "Below shows the username and password we are using in the otop_k_ini shell script"
echo
export load_path="/home/dw/DWLIVE/load/otop/"
#
> ${load_path}dummy_otop_k_ini.ksh
#
grep "user"  ${load_path}*otop_k_ini.ksh>${load_path}x.lis
rm ${load_path}dummy_*
#
cat ${load_path}x.lis|grep -v "#"|grep -v "aptostest"
#
rm ${load_path}x.lis
echo
echo "__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__"
echo
#Create an ftp control file for logging in to anite. This is the only way we could use a variable during ftp

export reqchek_path="/home/dw/DWLIVE/early_mkt_req/"
>${reqchek_path}reqchek.ctl
cd ${reqchek_path}
echo open cray >> ${reqchek_path}reqchek.ctl
echo user data_w valerian6 >> ${reqchek_path}reqchek.ctl
echo cd otop_pcd: >> ${reqchek_path}reqchek.ctl
echo pwd >> ${reqchek_path}reqchek.ctl
echo "ls mis_req_mkt_${tomorrow_1}.*" >> ${reqchek_path}reqchek.ctl
echo quit >> ${reqchek_path}reqchek.ctl

echo "Using this control file we just check that we can reach the otop_pcd directory of Anite's Alpha1" 
echo "-where our requesters are lodged and where the datafiles are written to."
echo "And  also check whether early market requesters (for use tomorrow) are in place."
echo 
ftp -nvi < ${reqchek_path}reqchek.ctl
echo
echo "__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__"
echo
echo "Below we just check that we can reach merlinlive" 
echo 
ftp -nvi <<\marker_1
open merlinlive
user dw DWhouse
quit
marker_1
echo
echo "__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__"
echo
echo "Below we check to see if PK_INTEGRATION is in a valid state"
echo
echo "If there is nothing between the following RS lines then it is OK"
sqlplus -s dw/dbp @/home/dw/bin/pk_int_test.sql /home/dw/bin/pk_int_test.lis
echo
echo "--___/R\_*|*_/S\___--"
cat /home/dw/bin/pk_int_test.lis
echo "--___/R\_*|*_/S\___--"
echo
echo "Below we check the seasons running DAS Redo"
echo
sqlplus -s dw/dbp @/home/dw/bin/das_redo_reqd.sql 
echo
echo "__/\__/\__/\__/\__"
echo "Below we check the normal redo seasons by grepping redo_line.ksh"
echo 
cat /home/dw/DWLIVE/fin_calc/redo_line.ksh|grep "season="|grep -v "#"
echo
echo
echo "Filesystem occupation for tourops, apps(=/home/dw) and archive is shown between the following RS lines"
echo "--=<\_/R\_>X<_/S\_/>=--"
df -k |grep "Filesystem"
echo "-----------------------------------------------------------------------"
df -k |grep "tourops"
df -k |grep "apps"
df -k |grep "var"
df -k |grep "tmp"
df -k |grep "archive"|grep -v "database"
echo "--=<\_/R\_>X<_/S\_/>=--"
echo
echo
cd /data
echo "Starting from directory "`pwd`" on the "${source}" box - and descending,"
echo "files above 10M (size shown in K) and not accessed for two days are listed"
echo "between the following RS lines and sorted with largest at the top."
echo "--=<\_/R\_>X<_/S\_/>=--"
find . -type f -size +10485760c -atime +2 -exec ls -1s "{}" \;|sort -nr
echo "--=<\_/R\_>X<_/S\_/>=--"
#
echo
cd /home/dw
echo "Starting from directory "`pwd`" on the "${source}" box - and descending,"
echo "files above 10M (size shown in K) and not accessed for two days are listed"
echo "between the following RS lines and sorted with largest at the top."
echo "--=<\_/R\_>X<_/S\_/>=--"
find . -type f -size +10485760c -atime +2 -exec ls -1s "{}" \;|sort -nr
echo "--=<\_/R\_>X<_/S\_/>=--"
echo
echo "__/\__/\__/\__/\__"
echo "__/\__/\__/\__/\__"
echo THIS CAME FROM THE ${source} BOX
echo "."
