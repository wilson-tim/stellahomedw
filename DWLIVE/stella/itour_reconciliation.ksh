#!/bin/ksh
#set -x

#############################################################################################
#
# 
#
#--------------------------------------------------------------------------------------------
# Change
# ------
#
# Date          Who     Description
# ----          ---     -----------
# 14/01/2004    Jyoti    Created script
#
#############################################################################################
# Input Parameters
# ----------------
#
# None
#
############################################################################################


function report
{
   echo `date +%Y/%m/%d---%H:%M:%S` $*
}

appdir="/home/dw/DWLIVE/stella"
logdir="/home/dw/SQL_Output"
today_d=`date +%Y%b%d`
today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`
PASSWD=`cat /home/dw/DWLIVE/passwords/stellabatch.txt`
mail_list="${appdir}/appsupportmail.lst"
user_mail_list="${appdir}/usermail.lst"
echo $PASSWD 

report "--------------------------------------------------------------------------"
report ">>>>>> Itour reconciliation to Stella Report"
report "--------------------------------------------------------------------------"

# Setting variables
report "Setting variables"
. /home/dw/bin/set_oracle_variables.ksh

logfile=$appdir/run_itour_reconcilication.lst


report "Run the stored proc that runs the report"
sqlplus -L stellabatch/$PASSWD  @$appdir/run_itour_reconciliation.sql > $logfile

report "display logfile contents:"
cat $logfile

report "Test for errors"
echo "Logfile:" $logfile
rm $appdir/itourrecon_error.err
grep "Fail" $logfile > $appdir/itourrecon_error.err 
grep "Error" $logfile >> $appdir/itourrecon_error.err
grep "ERROR" $logfile >> $appdir/itourrecon_error.err
grep "error " $logfile >> $appdir/itourrecon_error.err
grep "SEVERE" $logfile >> $appdir/itourrecon_error.err
grep "WARNING" $logfile >> $appdir/itourrecon_error.err
grep "CRITICAL" $logfile >> $appdir/itourrecon_error.err
grep "PLS-" $logfile >> $appdir/itourrecon_error.err
grep "ORA-" $logfile >> $appdir/itourrecon_error.err
# -s tests that size > 0 bytes
report "Need error email?"
if [ -s $appdir/itourrecon_error.err ]
 then
   echo "error found"
   echo >>  $appdir/itourrecon_error.err
   cat ${mail_list}|while read users
   do
     mailx -s "ERRORS `hostname` Details of Itour to Stella Reconciliation on "$today_d" " ${users}  <  $appdir/itourrecon_error.err
   done


fi

report "email summary"
echo "Logfile:" $logfile
grep "Rows " $logfile > $appdir/itourrecon_summ.lst
# -s tests that size > 0 bytes
report "Need summ email?"
if [ -s $appdir/itourrecon_summ.lst ]
 then
   echo "summ found"
   echo >>  $appdir/itourrecon_summ.lst
   cat ${user_mail_lst} ${mail_list}|while read users
   do
     mailx -s "STELLA `hostname` Summary of Itour to Stella Reconciliation on "$today_d" " ${users}  <  $appdir/itourrecon_summ.lst
   done


fi


report "END OF PROGRAM" 
exit 0
