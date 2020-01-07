#!/usr/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
dbase_id=DWL
home="/home/dw/"$dbase_id                     #  home path
stella_path=$home"/stella"                  #  Path for the app files
# run main mapping script and redirect output to date-stamped log file
$stella_path/load_bsp.ksh  >$home/logs/stella/load_bsp`date +%Y%m%d`.log 2 >>$home/logs/stella/load_bsp`date +%Y%m%d`.log
