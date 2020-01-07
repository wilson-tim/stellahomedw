#!/bin/ksh
echo ">>>>> Data Warehouse Integration Started" `date`
echo "-------------------------------------------------------------------------------------------------" 
#
if [ -a /home/dw/DWLIVE/logs/int_dw`date +%y%m%d`.log1 ]
then
  /usr/bin/rm /home/dw/DWLIVE/logs/int_dw`date +%y%m%d`.log1
fi
if [ -a /home/dw/DWLIVE/logs/int_dw`date +%y%m%d`.log2 ]
then
  /usr/bin/rm /home/dw/DWLIVE/logs/int_dw`date +%y%m%d`.log2
fi
#
  /home/dw/DWLIVE/integration/int_k_ctrl.ksh DWLIVE 1>> /home/dw/DWLIVE/logs/int_dw`date +%y%m%d`.log1  \
                                                    2>> /home/dw/DWLIVE/logs/int_dw`date +%y%m%d`.log2
#
