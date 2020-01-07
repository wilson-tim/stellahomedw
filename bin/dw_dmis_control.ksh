#!/usr/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
#This is dw_dmis_control.ksh stored in /home/dw/bin



echo ">>>>> Data Warehouse Hourly Market Update (dmis)   Started " `date`
#Below removes logs already existing

if [ -f /home/dw/DWLIVE/logs/dmis/int_dmis`date +%y%m%d`.log1 ]
then
  /usr/bin/rm /home/dw/DWLIVE/logs/dmis/int_dmis`date +%y%m%d`.log1
fi
if [ -f /home/dw/DWLIVE/logs/dmis/int_dmis`date +%y%m%d`.log2 ]
then
  /usr/bin/rm /home/dw/DWLIVE/logs/dmis/int_dmis`date +%y%m%d`.log2
fi
#
#
#
/home/dw/DWLIVE/integration/int_k_dmis_ctrl.ksh  1>> /home/dw/DWLIVE/logs/dmis/int_dmis`date +%y%m%d`.log1  \
                                                         2>> /home/dw/DWLIVE/logs/dmis/int_dmis`date +%y%m%d`.log2

echo ">>>>> Data Warehouse Hourly Market Update (dmis)   Ended   " `date`
echo "-------------------------------------------------------------------------------------------------"
