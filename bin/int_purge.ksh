#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
#int_purge.ksh:    Rob_S
#Now that the int files in /data/tourops are used to determine the seasonal completion of 
#integration, it is crucial that old ones are deleted before fresh integrations start.
#This purges them at (I suggest) 23:30. Also purge them before any one-off integrations.
#Call with:-
#30 23 * * * /home/dw/bin/int_purge.ksh 1>/home/dw/DWLIVE/logs/otop/int_purge.log 2>&1

dt_path="/data/tourops/"
rm ${dt_path}int_???.???

