#!/usr/bin/ksh
#--------=<\_/R\_>X<_/S\_/>=---------------------------
#This is /home/dw/bin/dmis_daily_purge.ksh
#Call with a cronline like:-
#59 23 * * * /home/dw/bin/dmis_daily_purge.ksh 1>/data/dmis/purge_log/dmis_daily_purge.log  2>&1
set -x
export log_path="/home/dw/DWLIVE/logs/dmis/"
export data_path="/data/dmis/"
export chek_path="/home/dw/DWLIVE/integration/chekrun/"
#-------=<\_/R\_>X<_/S\_/>=----------------------------
echo ${log_path}*|xargs rm
rm ${chek_path}*
#
for x in $(ls -1 ${data_path}*)
do
if [[ ${x%%_*} != ${data_path}last ]] then
rm ${x}
fi
done
#--------=<\_/R\_>X<_/S\_/>=---------------------------
