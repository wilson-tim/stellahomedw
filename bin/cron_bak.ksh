#!/bin/ksh
#This is cron_bak.ksh
#Call with cronline like:-    59 23 * * * /home/dw/bin/cron_bak.ksh  1>/dev/null 2>&1
typeset -l today
export today_d=`date +%Y%b%d`

crontab -l>/home/dw/rob/cron_bak/dw_cron.${today_d} 
