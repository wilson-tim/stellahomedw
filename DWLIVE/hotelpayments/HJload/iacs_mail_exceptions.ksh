#!/usr/bin/ksh
#_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
#Leigh oct02
#_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
. /home/dw/bin/set_oracle_variables.ksh
dbase_id=DWLIVE
home="/home/dw/"$dbase_id                              #  home path

iacs_path=$home"/hotelpayments/HJload"               #  Path for the app files
# mail users if there are new pricing records
echo "checking for new exception records"
# remove old file
# 
rm $iacs_path/HJexceptions.lst
sqlplus -s  iacs/iacs @$iacs_path/iacs_mail_exceptions.sql >> $iacs_path/HJexceptions.lst

MAILRECIPS=$iacs_path/mailrecips.lst
 # -s tests that size > 0 bytes
if [ -s $iacs_path/HJexceptions.lst ]
 then
   echo "new exceptionsfound" 

   for users in `cat $MAILRECIPS`
   do

     echo $users
     mailx -s "H&J IACS exceptions encountered in last 7 days"  $users <  $iacs_path/HJexceptions.lst
   done

 fi


