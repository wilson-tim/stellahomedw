#!/usr/bin/ksh
export JAVA_HOME="/usr/lib/sun/current/jre"
. /home/dw/bin/set_oracle_variables.ksh
dbase_id=DWL
home="/home/dw/"$dbase_id                     #  home path
stella_path=$home"/stella"                  #  Path for the app files
# move and rename files...
/home/dw/bin/move-ftp-tmp.sh
# run main mapping script and redirect output to date-stamped log file
echo "####################################################" >> $home/logs/stella/load_air`date +%Y%m%d`.log
#$stella_path/load_air.ksh  >$home/logs/stella/load_air`date +%Y%m%d`.log 2 >>$home/logs/stella/load_air`date +%Y%m%d`.log
$stella_path/load_air.ksh &>> $home/logs/stella/load_air`date +%Y%m%d`.log

