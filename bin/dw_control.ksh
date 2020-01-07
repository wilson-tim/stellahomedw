#!/bin/ksh

version=DWLIVE

echo "-------------------------------------------------------------------------------------------------" 
echo ">>>>> Data Warehouse $version Integration Started " `date`

if [ -f /home/dw/$version/logs/int_dw`date +%y%m%d`.log1 ]
then
  /usr/bin/rm /home/dw/$version/logs/int_dw`date +%y%m%d`.log1
fi
if [ -f /home/dw/$version/logs/int_dw`date +%y%m%d`.log2 ]
then
  /usr/bin/rm /home/dw/$version/logs/int_dw`date +%y%m%d`.log2
fi

if [[ `ps gw | grep "int_k_ctrl.ksh $version" | grep -v grep | wc -l` -ne 0 ]] then
       echo "******************************************************************"
       echo "***** PROCESS INT_K_CTRL.KSH ALREADY RUNNING, CANNOT RESTART *****"
       echo "******************************************************************"
       exit
fi 

/home/dw/$version/integration/int_k_ctrl.ksh $version    1>> /home/dw/$version/logs/int_dw`date +%y%m%d`.log1  \
                                                         2>> /home/dw/$version/logs/int_dw`date +%y%m%d`.log2

echo ">>>>> Data Warehouse $version Integration Ended   " `date`
echo "-------------------------------------------------------------------------------------------------"
