#!/bin/ksh
echo ">>>>> Data Warehouse Guarantee Exposure Process: Started" `date`
echo "-------------------------------------------------------------------------------------------------" 
#
/home/dw/DWLIVE/fin_calc/fc_confd.ksh DWLIVE > /home/dw/DWLIVE/logs/fin_calc/fc_confd`date +%y%m%d`.log
#
