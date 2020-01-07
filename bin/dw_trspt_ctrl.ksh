#!/bin/ksh
echo ">>>>> Data Warehouse Contract Transport Process: Started" `date`
echo "-------------------------------------------------------------------------------------------------" 
#
/home/dw/DWLIVE/fin_calc/fc_trspt_ctrl.ksh DWLIVE > /home/dw/DWLIVE/logs/fin_calc/fc_trspt`date +%y%m%d`.log
#
