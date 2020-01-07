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
# 30/4/2003    Leigh     Created script
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
echo $PASSWD 

report "--------------------------------------------------------------------------"
report ">>>>>> DWHSE Gemini reconciliation to Stella Report"
report "--------------------------------------------------------------------------"

# Setting variables
report "Setting variables"
. /home/dw/bin/set_oracle_variables.ksh

logfile=$appdir/run_gemini_reconcilication.lst


report "Run the stored proc that runs the report"
sqlplus  stellabatch/$PASSWD  @$appdir/run_gemini_reconciliation.sql > $logfile

report "display logfile contents:"
cat $logfile

report "Test for errors"
echo "Logfile:" $logfile
grep "Fail" $logfile > $appdir/gemrecon_error.err 
grep "Error" $logfile >> $appdir/gemrecon_error.err
grep "ERROR" $logfile >> $appdir/gemrecon_error.err
grep "error " $logfile >> $appdir/gemrecon_error.err
grep "SEVERE" $logfile >> $appdir/gemrecon_error.err
grep "WARNING" $logfile >> $appdir/gemrecon_error.err
grep "CRITICAL" $logfile >> $appdir/gemrecon_error.err
# -s tests that size > 0 bytes
report "Need error email?"
if [ -s $appdir/gemrecon_error.err ]
 then
   echo "error found"
   echo >>  $appdir/gemrecon_error.err
   cat ${mail_list}|while read users
   do
     mailx -s "ERRORS `hostname` Details of dwhse/Gemini to Stella Reconciliation on "$today_d" " ${users}  <  $appdir/gemrecon_error.err
   done


fi

report "email summary"
echo "Logfile:" $logfile
grep "Rows " $logfile > $appdir/gemrecon_summ.lst
# -s tests that size > 0 bytes
report "Need summ email?"
if [ -s $appdir/gemrecon_summ.lst ]
 then
   echo "summ found"
   echo >>  $appdir/gemrecon_summ.lst
   cat ${mail_list}|while read users
   do
     mailx -s "STELLA `hostname` Summary of dwhse/Gemini to Stella Reconciliation on "$today_d" " ${users}  <  $appdir/gemrecon_summ.lst
   done


fi


report "END OF PROGRAM" 
exit 0
