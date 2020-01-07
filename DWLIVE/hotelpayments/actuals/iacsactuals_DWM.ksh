

##############################################################################################################################

# ACTUALS FEEDBACK PROCESS 

#This program will take each of zip file from /data/hotelpayments/import directory 
# unzip them
# and load it into the temporary tables and , SQL scripts are called to load actual tables 


# It takes backup of zip file into /data/hotelpayments/import/backup and 
# creates Log file and data file into Logdata and Baddata dir respectively


# act_book.1 is not used as we don't need to load Booking table 


#  Developed By : Jyoti Renganathan  



#############################################################################################################################



dbase_id=DWLIVE
. /home/dw/bin/set_oracle_variables.ksh

#export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:.
#export ORACLE_HOME=/oracle
#export ORACLE_TERM=vt220
#export ORACLE_SID=DWL 
#export ORACLE_DOC=/oracle/odoc
#export LD_LIBRARY_PATH=$ORACLE_HOME/lib
#export PATH=$ORACLE_HOME/bin:$PATH
#export GMS_QUERY_FILE=/dev/rvsd_gms
#export GMS_NODE_LIST=/oracle/dbs/gms.nodes
#export GMS_HC_SOCKET=/tmp/serv.hc
#export GMS_LOG_DIR=/oracle/rdbms/log/gms.log

export USER=iacs
export PASSD=iacs


today_d=`date +%Y%b%d`
today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`

home="/home/dw/"$dbase_id                              #  home path 
lg_path=$home"/logs/"                                  #  Path for SQL*LOAD Log,Discard and Bad File
f_log_path=$lg_path"hotelpayments"                     #  Path for output from Jobs
iacs_path=$home"/hotelpayments/actuals/"               #  Path for the hotelpayments Loader ctl sourcce file
zipfile_path="/data/hotelpayments/import"
baddata_path="$zipfile_path/baddata"                   #  Path for .bad data created by loader script

echo "ACTUALS FEEDBACK STARTED" > $f_log_path/iacsactuals$today_d.log
date >>  $f_log_path/iacsactuals$today_d.log
 
#  Do all zip files from one Resort
for filename in  $zipfile_path/*.zip
do

# Test if filename specified by the variable $filename exists and is a regular file
if test ! -f $filename
   then
     echo "File doesn't exist for loading"
     exit
#break
fi

# Datetime stamp for bad files
_DATESTMP=`date +%d%m%y%H%M%S`

# take a temporary copy of zip file 
cp $filename $zipfile_path/temp.zip

# -o : overwrite without asking , -j : Do not create any dirs , -d : copy unzipped files to other dirs
unzip -j -o $zipfile_path/temp.zip  -d  $zipfile_path >> $f_log_path/iacsactuals$today_d.log

rm $zipfile_path/temp.zip  >> $f_log_path/iacsactuals$today_d.log 

# Take a backup of actuals files   
#cp $zipfile_path/act_*.* $zipfile_path/backup >> $f_log_path/iacsactuals$today_d.log
mv $filename $zipfile_path/backup >> $f_log_path/iacsactuals$today_d.log

# Move Data files into some temporary files (*.b) 
mv $zipfile_path/act_accom.* $zipfile_path/act_accom.b >> $f_log_path/iacsactuals$today_d.log
mv $zipfile_path/act_inv.* $zipfile_path/act_inv.b >> $f_log_path/iacsactuals$today_d.log
mv $zipfile_path/act_accom_inv.* $zipfile_path/act_accom_inv.b >> $f_log_path/iacsactuals$today_d.log
mv $zipfile_path/act_extra.*  $zipfile_path/act_extra.b >> $f_log_path/iacsactuals$today_d.log
mv $zipfile_path/act_invextra.*  $zipfile_path/act_invextra.b >> $f_log_path/iacsactuals$today_d.log

# Remove ctrl-M from each file
sed "s///g" $zipfile_path/act_accom.b > $zipfile_path/act_accom.a
sed "s///g" $zipfile_path/act_inv.b > $zipfile_path/act_inv.a
sed "s///g" $zipfile_path/act_accom_inv.b > $zipfile_path/act_accom_inv.a
sed "s///g" $zipfile_path/act_extra.b > $zipfile_path/act_extra.a
sed "s///g" $zipfile_path/act_invextra.b >  $zipfile_path/act_invextra.a


echo " LOADING BOOKING ACCOMS "   >>  $f_log_path/iacsactuals$today_d.log
echo " -----------------------"  >>  $f_log_path/iacsactuals$today_d.log
sqlldr $USER/$PASSD  "$iacs_path"act_accom.ctl log="$zipfile_path/logdata/act_accom_$_DATESTMP.log" bad="$zipfile_path/baddata/act_accom_$_DATESTMP.bad">> $f_log_path/iacsactuals$today_d.log errors=1000000


echo "LOADING FROM TEMP_BOOKING_ACCOM TO BOOKING_ACCOM " >> $f_log_path/iacsactuals$today_d.log
echo "------------------------------------------------ " >>  $f_log_path/iacsactuals$today_d.log
sqlplus $USER/$PASSD @"$iacs_path"book_accom.sql >> $f_log_path/iacsactuals$today_d.log

echo " LOADING INVOICES "  >> $f_log_path/iacsactuals$today_d.log
echo " ---------------- " >>  $f_log_path/iacsactuals$today_d.log
sqlldr $USER/$PASSD "$iacs_path"act_inv.ctl log="$zipfile_path/logdata/act_inv_$_DATESTMP.log"  bad="$zipfile_path/baddata/act_inv_$_DATESTMP.bad">> $f_log_path/iacsactuals$today_d.log errors=1000000

echo "LOADING FROM TEMP_INVOICE TO INVOICE " >> $f_log_path/iacsactuals$today_d.log
echo "------------------------------------------------ " >>  $f_log_path/iacsactuals$today_d.log

sqlplus $USER/$PASSD @"$iacs_path"inv.sql >> $f_log_path/iacsactuals$today_d.log

echo " LOADING BOOKING ACCOM INVOICE " >> $f_log_path/iacsactuals$today_d.log
echo " -----------------------------"  >>  $f_log_path/iacsactuals$today_d.log
sqlldr $USER/$PASSD  "$iacs_path"act_accom_inv.ctl log="$zipfile_path/logdata/act_accom_inv_$_DATESTMP.log" bad="$zipfile_path/baddata/act_accom_inv_$_DATESTMP.bad" >> $f_log_path/iacsactuals$today_d.log errors=1000000

echo "LOADING FROM TEMP_BOOKING_ACCOM_INVOICE TO BOOKING_ACCOM_INVOICE " >> $f_log_path/iacsactuals$today_d.log
echo "------------------------------------------------ " >>  $f_log_path/iacsactuals$today_d.log
sqlplus $USER/$PASSD @"$iacs_path"book_accom_inv.sql >> $f_log_path/iacsactuals$today_d.log

echo " LOADING BOOKING ACCOM EXTRA " >> $f_log_path/iacsactuals$today_d.log
echo " ---------------------------"  >>  $f_log_path/iacsactuals$today_d.log
sqlldr $USER/$PASSD "$iacs_path"act_extra.ctl log="$zipfile_path/logdata/act_extra_$_DATESTMP.log" bad="$zipfile_path/baddata/act_extra_$_DATESTMP.bad" >> $f_log_path/iacsactuals$today_d.log errors=1000000

echo "LOADING FROM TEMP_BOOKING_ACCOM_EXTRAS TO BOOKING_ACCOM_EXTRAS " >> $f_log_path/iacsactuals$today_d.log
echo "------------------------------------------------ " >>  $f_log_path/iacsactuals$today_d.log
sqlplus $USER/$PASSD @"$iacs_path"book_accom_extra.sql >> $f_log_path/iacsactuals$today_d.log

echo " LOADING INVOICE EXTRA " >> $f_log_path/iacsactuals$today_d.log
echo " ----------------------"  >>  $f_log_path/iacsactuals$today_d.log
sqlldr $USER/$PASSD "$iacs_path"act_invextra.ctl log="$zipfile_path/logdata/act_invextra_$_DATESTMP.log" bad="$zipfile_path/baddata/act_invextra_$_DATESTMP.bad" >> $f_log_path/iacsactuals$today_d.log errors=1000000

echo "LOADING FROM TEMP_INVOICE_EXTRAS TO INVOICE_EXTRAS " >> $f_log_path/iacsactuals$today_d.log
echo "------------------------------------------------ " >>  $f_log_path/iacsactuals$today_d.log
sqlplus $USER/$PASSD @"$iacs_path"inv_extra.sql >> $f_log_path/iacsactuals$today_d.log

# Remove actual file from working directory
rm $zipfile_path/act_*.*

done 

date >>  $f_log_path/iacsactuals$today_d.log
echo "ACTUALS FEEDBACK FINISHED !!! " >> $f_log_path/iacsactuals$today_d.log


echo $temp  ##  for debug

# remove old file
rm $iacs_path/iacs_error.err
sqlplus -s iacs/iacs @$iacs_path/iacs_error >> $iacs_path/iacs_error.err

 # -s tests that size > 0 bytes
if [ -s $iacs_path/iacs_error.err ]
 then
echo "error found" 
mailx -s "Details of IACS feedback/loader messages errors encountered  on "$today_d" " paul.g.butler@firstchoice.co.uk <  $iacs_path/iacs_error.err

 fi

if test -f $baddata_path/*.bad
 then
mail_txt=" ~~~   Bad data load file exists in $baddata_path directory.  "
fi

#if test $temp  >  0; then
if test $temp -ne "0"   # comparing as a string rather then number
then
mail_txt=$mail_txt"~~~       $temp record/s found in loader_msgs table.  ~~~"
fi

if [[ -n $mail_txt ]]
then
   mail_txt=$mail_txt"Actuals feedback process is not finished successfully on "$today_d".  Please investigate."
   echo $mail_txt
   echo $mail_txt 2>&1 |  mailx -s "IACS Feedback errors" paul.g.butler@firstchoice.co.uk
fi









