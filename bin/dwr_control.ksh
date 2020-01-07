#!/bin/ksh



echo ">>>>> Data Warehouse Retail  Integration Started " `date`

if [ -f /home/dw/DWLIVE/logs/int_dwr`date +%y%m%d`.log1 ]
then
  /usr/bin/rm /home/dw/DWLIVE/logs/int_dwr`date +%y%m%d`.log1
fi
if [ -f /home/dw/DWLIVE/logs/int_dwr`date +%y%m%d`.log2 ]
then
  /usr/bin/rm /home/dw/DWLIVE/logs/int_dwr`date +%y%m%d`.log2
fi

if [[ `ps gw | grep "int_k_retail_ctrl.ksh" | grep -v grep | wc -l` -ne 0 ]] then
       echo "******************************************************************"
       echo "***** PROCESS INT_K_RETAIL_CTRL.KSH ALREADY RUNNING, CANNOT RESTART *****"
       echo "******************************************************************"
       exit
fi 


/home/dw/DWLIVE/integration/int_k_retail_ctrl.ksh  1>> /home/dw/DWLIVE/logs/int_dwr`date +%y%m%d`.log1  \
                                                         2>> /home/dw/DWLIVE/logs/int_dwr`date +%y%m%d`.log2

echo ">>>>> Data Warehouse Retail Integration Ended   " `date`
echo "-------------------------------------------------------------------------------------------------"
