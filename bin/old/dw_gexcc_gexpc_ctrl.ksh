#
echo ">>>>> Data Warehouse Guarantee Exposure Process: Started" `date`
echo "-------------------------------------------------------------------------------------------------" 
#
/home/dw/DWLIVE/fin_calc/fc_gexcc_gexpc.ksh DWLIVE > /home/dw/DWLIVE/logs/fin_calc/fc_gexcc_gexpc`date +%y%m%d`.log
#
