#!/usr/bin/ksh
######################################################################################################
#
# PROGRAM:  iacs_tl_load_all.ksh
#
# DATE        BY  DESCRIPTION
# ----        --  -----------
#
# 12/06/02     JR  Initial Version.
# 17/12/02     LA  Allocate more memory to java xmlload
# 08/09/03     JR  Allocae more memory to Java XML booking load using http2ftp, added -mx256m for booking.xml
# 08/06/05     PB  Cloned from iacs_hj_load_all.ksh and changed for Travelink load
# 
# Script to load into datawarehouse-iacs tables from xml files provided by Hayes & Jarvis
# Step 1 : Fetch files from remote H&J server using http , this will create .xml files into /data/hotelpayments/XMLFILES
# Step 2 : Reference and Booking files will be loaded first into temp tables using Oracle PutXML 
# Step 3 : Reference and Booking data loaded into actual tables using pl sql program 
#
# #######################################################################################################
#
# Set ClassPath variable 

# Set oracle variables
#
. /home/dw/bin/set_oracle_variables.ksh
. /home/dw/bin/set_java_variables.ksh

today_d=`date +%Y%b%d`

case $ORACLE_SID in
   DWD) java_conn="jdbc:oracle:thin:@dwdev:1521:dwd";;
   DWT) java_conn="jdbc:oracle:thin:@dwtest:1521:dwt";;
   DWL) java_conn="jdbc:oracle:thin:@slo-dwlive:1521:dwl";;
esac

dbase_id=DWLIVE
home="/home/dw/"$dbase_id                         # Home path
lg_path=$home"/logs/"    
f_log_path=$lg_path"hotelpayments"                # Path for output from jobs
iacs_path=$home"/hotelpayments/TLload"            # Path for the Travelink hotel payments sql source files
dest_dir='/data/hotelpayments/XMLFILES'           # Destination Path for xml files from Travelink
zip_path="/data/hotelpayments/XMLFILES/"          # Path for zip files
travelink_dir='.'
IP_address=`cat $iacs_path/Travelink_ip_address.txt`
userlog=`cat $iacs_path/Travelink_userlog.txt`
userpass=`cat $iacs_path/Travelink_password.txt`

echo "IACS Travelink Load started on " >  $f_log_path/iacsTLload_all$today_d.log 
hostname >> $f_log_path/iacsTLload_all$today_d.log 

date >> $f_log_path/iacsTLload_all$today_d.log 

########################################################################################################################
# Step 1 : Get remote Travelink .xml files from their server using ftp and place in /data/hotelpayments/XMLFILES
########################################################################################################################

#/home/dw/bin/fch_ftp.ksh ${IP_address} ${userlog} ${userpass} ${travelink_dir} Location_tl.xml ${dest_dir} Location_tl.xml >>  $f_log_path/iacsTLload_all$today_d.log 2>&1
#/home/dw/bin/fch_ftp.ksh ${IP_address} ${userlog} ${userpass} ${travelink_dir} Property_tl.xml ${dest_dir} Property_tl.xml >>  $f_log_path/iacsTLload_all$today_d.log 2>&1
#/home/dw/bin/fch_ftp.ksh ${IP_address} ${userlog} ${userpass} ${travelink_dir} Bookings_tl.xml ${dest_dir} Bookings_tl.xml >>  $f_log_path/iacsTLload_all$today_d.log 2>&1
#/home/dw/bin/fch_ftp.ksh ${IP_address} ${userlog} ${userpass} ${travelink_dir} BookingAccom_tl.xml ${dest_dir} BookingAccom_tl.xml >>  $f_log_path/iacsTLload_all$today_d.log 2>&1


#######################################################################################################################
# Step 2 : Reference and  Booking files will be loaded first into temp tables using Oracle PutXML
#######################################################################################################################
#date >> $f_log_path/iacsTLload_all$today_d.log 
#echo "Loading Travelink Reference data into temporary tables " >>  $f_log_path/iacsTLload_all$today_d.log 

# Check Reference data xml files are ok first
#echo "Checking for invalid Reference data xml files" >> $f_log_path/iacsTLload_all$today_d.log
#grep -i  'could not find' /data/hotelpayments/XMLFILES/Location_tl.xml
#grep_status=$?
#if [[ $grep_status -eq 0 ]] then
#   echo " " >> $f_log_path/iacsTLload_all$today_d.log
#   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/Location_tl.xml >> $f_log_path/iacsTLload_all$today_d.log
#   echo " " >> $f_log_path/iacsTLload_all$today_d.log
#fi
#grep -i  'could not find' /data/hotelpayments/XMLFILES/Property_tl.xml
#grep_status=$?
#if [[ $grep_status -eq 0 ]] then
#   echo " " >> $f_log_path/iacsTLload_all$today_d.log
#   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/Property_tl.xml >> $f_log_path/iacsTLload_all$today_d.log
#   echo " " >> $f_log_path/iacsTLload_all$today_d.log
#fi


#java OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag LOCATION -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/Location_tl.xml  temp_xml_location >>  $f_log_path/iacsTLload_all$today_d.log 2>&1
# Check some rows were loaded
#grep -i "rows into temp_xml_location" $f_log_path/iacsTLload_all$today_d.log
#grep_status=$?
#if [[ $grep_status != 0 ]] then
#   echo "*** ERROR - MISSING ROWS from Location_tl.xml ***"  >> $f_log_path/iacsTLload_all$today_d.log
#fi

#java OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag PROPERTY -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/Property_tl.xml  temp_xml_property >>  $f_log_path/iacsTLload_all$today_d.log 2>&1
# Check some rows were loaded
#grep -i "rows into temp_xml_property" $f_log_path/iacsTLload_all$today_d.log
#grep_status=$?
#if [[ $grep_status != 0 ]] then
#   echo "*** ERROR - MISSING ROWS from Property_tl.xml ***"  >> $f_log_path/iacsTLload_all$today_d.log
#fi

date >> $f_log_path/iacsTLload_all$today_d.log  
echo "Loading Travelink booking and bookingaccom data into temporary tables " >>  $f_log_path/iacsTLload_all$today_d.log 

# Check Booking data xml files are ok next
echo "Checking for invalid Booking data xml files" >> $f_log_path/iacsTLload_all$today_d.log
grep -i  'could not find' /data/hotelpayments/XMLFILES/Bookings_tl.xml
grep_status=$?
if [[ $grep_status -eq 0 ]] then
   echo " " >> $f_log_path/iacsTLload_all$today_d.log
   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/Bookings_tl.xml >> $f_log_path/iacsTLload_all$today_d.log
   echo " " >> $f_log_path/iacsTLload_all$today_d.log
fi
grep -i  'could not find' /data/hotelpayments/XMLFILES/BookingAccom_tl.xml
grep_status=$?
if [[ $grep_status -eq 0 ]] then
   echo " " >> $f_log_path/iacsTLload_all$today_d.log
   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/BookingAccom_tl.xml >> $f_log_path/iacsTLload_all$today_d.log
   echo " " >> $f_log_path/iacsTLload_all$today_d.log
fi

java -mx512m OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag BOOKING -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/Bookings_tl.xml  temp_xml_booking >>  $f_log_path/iacsTLload_all$today_d.log 2>&1
# Check some rows were loaded
grep -i "rows into temp_xml_booking" $f_log_path/iacsTLload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
   echo "*** ERROR - MISSING ROWS from Bookings_tl.xml ***"  >> $f_log_path/iacsTLload_all$today_d.log
fi

java -mx512m OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag BOOKINGACCOM -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/BookingAccom_tl.xml  temp_xml_booking_accom >>  $f_log_path/iacsTLload_all$today_d.log 2>&1
# Check some rows were loaded
grep -i "rows into temp_xml_booking_accom" $f_log_path/iacsTLload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
   echo "*** ERROR - MISSING ROWS from BookingAccom_tl.xml ***"  >> $f_log_path/iacsTLload_all$today_d.log
fi

date >> $f_log_path/iacsTLload_all$today_d.log 

#######################################################################################################################
# Step 3 Reference and Booking data will be loaded fron temp tables to actual tables using pl sql program
########################################################################################################################
echo "Loading Travelink reference and Booking data into actual tables" >>  $f_log_path/iacsTLload_all$today_d.log 
sqlplus iacs/iacs @$iacs_path/iacs_tl_load.sql >> $f_log_path/iacsTLload_all$today_d.log 
date >> $f_log_path/iacsTLload_all$today_d.log 

#######################################################################################################################
# Now zip these files and move ref and booking file into backup dir
#######################################################################################################################
#echo "Travelink XML load finished now backing up the files" >>  $f_log_path/iacsTLload_all$today_d.log 
#date >> $f_log_path/iacsTLload_all$today_d.log 
#cd $zip_path

#for filename in `ls *tl.xml`
#do
#  zip TLxmlbkup$today_d.zip $filename  >>  $f_log_path/iacsTLload_all$today_d.log
#done
# Delete Travelink xml files
#rm *tl.xml

#cd $iacs_path

# Take backup of zip files
#mv -f $zip_path/TL*.zip $zip_path/backup

###############################################################################################################
# Delete any zip files older than 60 days
#  echo "About to delete the following Travelink backup files" >>  $f_log_path/iacsTLload_all$today_d.log 
#  find $zip_path/backup $zip_path/backup/TL*.*  -mtime +100 -exec   ls -ltr  {}  \;
#  find $zip_path/backup $zip_path/backup/TL*.*  -mtime +100 -exec   rm -f {} \; 

#date >>$f_log_path/iacsTLload_all$today_d.log 
#echo "FINISHED Travelink Load!" >> $f_log_path/iacsTLload_all$today_d.log &


 #################################################################################################################
# if Error in xml load then  send log file along with no. of records in iacs_general_error table to support team 
 #################################################################################################################

# Check for problems with xml files
#grep -i "ERROR" $f_log_path/iacsTLload_all$today_d.log
#grep_status=$?
#if [[ $grep_status != 0 ]] then
#    # xml files not invalid but also need to check if rows were loaded
#    grep -i "MISSING ROWS" $f_log_path/iacsTLload_all$today_d.log
#    grep_status=$?
#fi

sqlplus -s dw/dbp << !
set heading off
set termout off
set feedback off
set lines 2000
set echo off
set verify off
  
spool /home/dw/DWLIVE/hotelpayments/TLload/errorfile.err
select datetime_errors_found , parameter1, parameter2, error_code, description1
from iacs.iacs_general_error
where to_char(datetime_errors_found) = to_char(sysdate)
and description2 = 'Travelink';
exit
!
   
# -s tests that  size > 0 bytes
# $grep_status indicates error in xml files
if [[ -s $iacs_path/errorfile.err ]] | [[ $grep_status -eq 0 ]] then
   echo "Batch Program run on machine:" > $iacs_path/mail.lst
   hostname >> $iacs_path/mail.lst
   cat  $f_log_path/iacsTLload_all$today_d.log  >>  $iacs_path/mail.lst
   if [[ -s $iacs_path/errorfile.err ]] then
      echo ' Following records from iacs_general_error table are in error :' >> $iacs_path/mail.lst
   fi
   cat $iacs_path/errorfile.err >> $iacs_path/mail.lst
   echo "Error found"
   
#  mailx -s "DWHSE side : ERRORS in Travelink booking load into iacs datawarehouse" basds@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/TLload/mail.lst 
 # mailx -s "DWHSE side : ERRORS in Travelink booking load into iacs datawarehouse" jon.hollamby@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/TLload/mail.lst 
   mailx -s "DWHSE side : ERRORS in Travelink booking load into iacs datawarehouse" paul.g.butler@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/TLload/mail.lst 
 
#   mailx -s "DWHSE side : ERRORS in Travelink booking load into iacs datawarehouse" jyoti.renganathan@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/TLload/mail.lst 
 
#   mailx -s "DWHSE side : ERRORS in Travelink booking load into iacs datawarehouse" robert.gilliland@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/TLload/mail.lst 
fi
   

