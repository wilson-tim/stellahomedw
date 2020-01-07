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
echo $PASSWD 

report "--------------------------------------------------------------------------"
report ">>>>>> Stella Missing Ticket Report"
report "--------------------------------------------------------------------------"

# Setting variables
report "Setting variables"
. /home/dw/bin/set_oracle_variables.ksh

logfile=$appdir/run_missing_ticket_check.lst

error_mail_list="${appdir}/appsupportmail.lst"
user_mail_list="${appdir}/usermail.lst"

report "Run the stored proc that runs the report"
sqlplus  stellabatch/$PASSWD  @$appdir/run_missing_ticket_check.sql > $logfile

report "display logfile contents:"
cat $logfile

report "Test for errors"
echo "Logfile:" $logfile
grep "Fail" $logfile > $appdir/miss_error.err 
grep "Error " $logfile >> $appdir/miss_error.err
grep "ERROR" $logfile >> $appdir/miss_error.err
grep "error " $logfile >> $appdir/miss_error.err
grep "SEVERE" $logfile >> $appdir/miss_error.err
grep "WARNING" $logfile >> $appdir/miss_error.err
grep "CRITICAL" $logfile >> $appdir/miss_error.err
# -s tests that size > 0 bytes
report "Need error email?"
if [ -s $appdir/miss_error.err ]
 then
   echo "error found"
   echo >>  $appdir/miss_error.err
   cat ${error_mail_list}|while read users
   do
     echo ${users}
     mailx -s "Details of `hostname` STELLA Missing Ticket Report errors encountered  on "$today_d" " ${users} <  $appdir/miss_error.err
   done


fi

report "Now email the actual run report to users"
repfile=/home/dw/SQL_Output/stlmtktr.log
cat $repfile
if [ -s $repfile ]
 then
   echo "results file found"
   cat ${user_mail_list}|while read users
   do
     echo ${users}
     mailx -s "Details of `hostname` STELLA Missing Tickets encountered  on "$today_d" " ${users} <  $repfile
   done

fi


report "END OF PROGRAM" 
exit 0
