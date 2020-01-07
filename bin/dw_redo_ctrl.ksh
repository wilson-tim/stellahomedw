#!/bin/ksh
echo ">>>>> Data Warehouse Redo Calcualtions Process: Started" `date`
echo "-------------------------------------------------------------------------------------------------" 
#
/home/dw/DWLIVE/fin_calc/redo_line.ksh DWLIVE > /home/dw/DWLIVE/logs/fin_calc/dw_fcalc_redo`date +%y%m%d`.log
#
