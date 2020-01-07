##########################################################################################################
#
#  Script: DW_BTS_CTRL.KSH
#
#  Change Control
#  --------------
#
#  Date       Who Description 
#  ---------- --- ----------------------------------------------------------------------------------------
#  19/01/2000 DJH Added check to see if already running
#
##########################################################################################################
#
if [[ `ps gw | grep "/bts/b2s" | grep -v grep | wc -l` -ne 0 ]] then
   #
   echo "***** A Beds To Seats process is already running, cannot restart *****" `date`
   echo "-------------------------------------------------------------------------------------------------" 
   exit
   #
else
   #
   echo ">>>>> Beds To Seats Process Started" `date`
   echo "-------------------------------------------------------------------------------------------------" 
   /home/dw/DWLIVE/bts/b2s_int.ksh DWLIVE > /home/dw/DWLIVE/logs/bts/b2s_int`date +%y%m%d`.log
   #
fi
#
