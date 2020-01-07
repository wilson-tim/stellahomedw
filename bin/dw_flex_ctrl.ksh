#!/bin/ksh
echo ">>>>> Data Warehouse Contract Flexing Process: Started" `date`
echo "-------------------------------------------------------------------------------------------------" 
#
/home/dw/DWLIVE/fin_calc/fcalc_ctrl.ksh DWLIVE > /home/dw/DWLIVE/logs/fin_calc/fcalc_flex`date +%y%m%d`.log
#
echo ">>>>> Data Warehouse Contract Flexing Process: Started" `date`
echo "-------------------------------------------------------------------------------------------------"
