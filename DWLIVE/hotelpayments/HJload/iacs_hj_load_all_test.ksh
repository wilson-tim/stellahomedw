#!/usr/bin/ksh
######################################################################################################
#
# PROGRAM:  iacs_hj_load_all.ksh
#
# DATE        BY  DESCRIPTION
# ----        --  -----------
#
# 12/06/02     JR  Initial Version.
# 17/12/02     LA  Allocate more memory to java xmlload
# 08/09/03     JR  Allocae more memory to Java XML booking load using http2ftp, added -mx256m for booking.xml
# 06/07/05     PB  Handle invalid xml files.
#                  Set java database connection string dynamically.
#                  Increase memory allocation for java booking and booking_accom loads from 256 to 512
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
   DWL) java_conn="jdbc:oracle:thin:@dwlive:1521:dwl";;
esac

dbase_id=DWLIVE
home="/home/dw/"$dbase_id                   # Home path
lg_path=$home"/logs/"    
f_log_path=$lg_path"hotelpayments"          # Path for output from jobs
iacs_path=$home"/hotelpayments/HJload"      # Path for the hotel payments sql source files

zip_path="/data/hotelpayments/XMLFILES/"    # Path for zip files

echo "IACS Hayes&Jarvis Load started" >  $f_log_path/iacshjload_all$today_d.log 

date >> $f_log_path/iacshjload_all$today_d.log 

########################################################################################################################
# Step 1 : Fetch files from remote H&J server using http , this will create .xml files into /data/hotelpayments/SMLFILES
########################################################################################################################
#it calls TMS - database name hjtmsmis user name iacs/password ip addres is 10.8.253.60
#echo "Fetching reference and booking data file from H&J server " >>  $f_log_path/iacshjload_all$today_d.log 
#java http2file hjintranet 80 /sql/?sql=execute+hj_location?root=root /data/hotelpayments/XMLFILES/location.xml >>  $f_log_path/iacshjload_all$today_d.log 2>&1
#java http2file hjintranet 80 /sql/?sql=execute+hj_property?root=root /data/hotelpayments/XMLFILES/property.xml >>  $f_log_path/iacshjload_all$today_d.log 2>&1
#java http2file hjintranet 80 /sql/?sql=execute+hj_propertycode?root=root /data/hotelpayments/XMLFILES/propertycode.xml >>  $f_log_path/iacshjload_all$today_d.log 2>&1
#java -mx512m http2file hjintranet 80 /sql/?sql=execute+hj_booking?root=root /data/hotelpayments/XMLFILES/booking.xml >>  $f_log_path/iacshjload_all$today_d.log 2>&1
#java -mx512m http2file hjintranet 80 /sql/?sql=execute+hj_bookingaccom?root=root /data/hotelpayments/XMLFILES/bookingaccom.xml >>  $f_log_path/iacshjload_all$today_d.log 2>&1

#######################################################################################################################
# Step 2 : Reference and  Booking files will be loaded first into temp tables using Oracle PutXML
#######################################################################################################################
date >> $f_log_path/iacshjload_all$today_d.log 
echo "Loading Reference data into temporary tables " >>  $f_log_path/iacshjload_all$today_d.log 

# Check Reference data xml files are ok first
echo "Checking for invalid Reference data xml files" >> $f_log_path/iacshjload_all$today_d.log
grep -i  'could not find' /data/hotelpayments/XMLFILES/location.xml
grep_status=$?
if [[ $grep_status -eq 0 ]] then
   echo " " >> $f_log_path/iacshjload_all$today_d.log
   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/location.xml >> $f_log_path/iacshjload_all$today_d.log
   echo " " >> $f_log_path/iacshjload_all$today_d.log
fi
grep -i  'could not find' /data/hotelpayments/XMLFILES/property.xml
grep_status=$?
if [[ $grep_status -eq 0 ]] then
   echo " " >> $f_log_path/iacshjload_all$today_d.log
   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/property.xml >> $f_log_path/iacshjload_all$today_d.log
   echo " " >> $f_log_path/iacshjload_all$today_d.log
fi
grep -i  'could not find' /data/hotelpayments/XMLFILES/propertycode.xml
grep_status=$?
if [[ $grep_status -eq 0 ]] then
   echo " " >> $f_log_path/iacshjload_all$today_d.log
   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/propertycode.xml >> $f_log_path/iacshjload_all$today_d.log
   echo " " >> $f_log_path/iacshjload_all$today_d.log
fi

java OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag LOCATION -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/location.xml  temp_xml_location >>  $f_log_path/iacshjload_all$today_d.log 2>&1
# Check some rows were loaded
grep -i "rows into temp_xml_location" $f_log_path/iacshjload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
   echo "*** ERROR - MISSING ROWS from location.xml ***"  >> $f_log_path/iacshjload_all$today_d.log
fi


exit


java OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag PROPERTY -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/property.xml  temp_xml_property >>  $f_log_path/iacshjload_all$today_d.log 2>&1
# Check some rows were loaded
grep -i "rows into temp_xml_property" $f_log_path/iacshjload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
   echo "*** ERROR - MISSING ROWS from property.xml ***"  >> $f_log_path/iacshjload_all$today_d.log
fi

java OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag OTOP_PROPERTY -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/propertycode.xml  temp_xml_otop_property >>  $f_log_path/iacshjload_all$today_d.log 2>&1
# Check some rows were loaded
grep -i "rows into temp_xml_otop_property" $f_log_path/iacshjload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
   echo "*** ERROR - MISSING ROWS from propertycode.xml ***"  >> $f_log_path/iacshjload_all$today_d.log
fi

date >> $f_log_path/iacshjload_all$today_d.log 
echo "Loading HandJ booking and bookingaccom data into temporary tables " >>  $f_log_path/iacshjload_all$today_d.log 

# Check Booking data xml files are ok next
echo "Checking for invalid Booking data xml files" >> $f_log_path/iacshjload_all$today_d.log
grep -i  'could not find' /data/hotelpayments/XMLFILES/booking.xml
grep_status=$?
if [[ $grep_status -eq 0 ]] then
   echo " " >> $f_log_path/iacshjload_all$today_d.log
   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/booking.xml >> $f_log_path/iacshjload_all$today_d.log
   echo " " >> $f_log_path/iacshjload_all$today_d.log
fi
grep -i  'could not find' /data/hotelpayments/XMLFILES/bookingaccom.xml
grep_status=$?
if [[ $grep_status -eq 0 ]] then
   echo " " >> $f_log_path/iacshjload_all$today_d.log
   echo "*** ERROR INVALID XML FILE ***  "/data/hotelpayments/XMLFILES/bookingaccom.xml >> $f_log_path/iacshjload_all$today_d.log
   echo " " >> $f_log_path/iacshjload_all$today_d.log
fi

java -mx512m OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag BOOKING -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/booking.xml  temp_xml_booking >>  $f_log_path/iacshjload_all$today_d.log 2>&1
# Check some rows were loaded
grep -i "rows into temp_xml_booking" $f_log_path/iacshjload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
   echo "*** ERROR - MISSING ROWS from booking.xml ***"  >> $f_log_path/iacshjload_all$today_d.log
fi

java -mx512m OracleXML putXML -user "iacs/iacs" -conn $java_conn  -commitBatch 10 -rowTag BOOKINGACCOM -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/bookingaccom.xml  temp_xml_booking_accom >>  $f_log_path/iacshjload_all$today_d.log 2>&1
# Check some rows were loaded
grep -i "rows into temp_xml_booking_accom" $f_log_path/iacshjload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
   echo "*** ERROR - MISSING ROWS from bookingaccom.xml ***"  >> $f_log_path/iacshjload_all$today_d.log
fi

date >> $f_log_path/iacshjload_all$today_d.log 

#######################################################################################################################
# Step 3 Reference and Booking data will be loaded fron temp tables to actual tables using pl sql program
########################################################################################################################
echo "Loading H&J reference and Booking  data into actual tables" >>  $f_log_path/iacshjload_all$today_d.log 
sqlplus iacs/iacs @$iacs_path/iacs_hj_load >> $f_log_path/iacshjload_all$today_d.log 
date >> $f_log_path/iacshjload_all$today_d.log 

#######################################################################################################################
# Now zip these files and move ref and booking file into backup dir
#######################################################################################################################
echo "XML load finished now backing up the files" >>  $f_log_path/iacshjload_all$today_d.log 
date >> $f_log_path/iacshjload_all$today_d.log 
cd $zip_path

for filename in `ls *.xml`
do
  zip xmlbkup$today_d.zip $filename  >>  $f_log_path/iacshjload_all$today_d.log
done
cd $iacs_path


# Take backup of a zip files
mv -f $zip_path/*.zip $zip_path/backup

##############################################################################################
# Delete any zip files older than 60 days
  echo "About to delete the following backup files"
  find $zip_path/backup $zip_path/backup/*.*  -mtime +100 -exec   ls -ltr  {}  \;
  find $zip_path/backup $zip_path/backup/*.*  -mtime +100 -exec   rm -f {} \; 

date >>$f_log_path/iacshjload_all$today_d.log 
echo "FINISHED Hayes&Jarvis Load!" >> $f_log_path/iacshjload_all$today_d.log &


 ##############################################################################################
# if Error in xml load then  send log file along with no. of records in iacs_general_error table to support team 
 ##############################################################################################

# Check for problems with xml files
grep -i "ERROR" $f_log_path/iacshjload_all$today_d.log
grep_status=$?
if [[ $grep_status != 0 ]] then
    # xml files not invalid but also need to check if rows were loaded
    grep -i "MISSING ROWS" $f_log_path/iacshjload_all$today_d.log
    grep_status=$?
fi

sqlplus -s dw/dbp << !
set heading off
set termout off
set feedback off
set lines 2000
set echo off
set verify off
  
spool /home/dw/DWLIVE/hotelpayments/HJload/errorfile.err
select datetime_errors_found , parameter1, parameter2, error_code, description1
from iacs.iacs_general_error
where to_char(datetime_errors_found) = to_char(sysdate)
and (description2 <> 'Travelink' OR description2 IS NULL)
 and severity > 1;
exit
!
   
# -s tests that  size > 0 bytes
# $grep_status indicates error in xml files
if [[ -s $iacs_path/errorfile.err ]] | [[ $grep_status -eq 0 ]] then
   echo "Batch Program run on machine:" > $iacs_path/mail.lst
   hostname >> $iacs_path/mail.lst
   cat  $f_log_path/iacshjload_all$today_d.log  >>  $iacs_path/mail.lst
   if [[ -s $iacs_path/errorfile.err ]] then
      echo ' Following records from iacs_general_error table are in error :' >> $iacs_path/mail.lst
   fi
   cat $iacs_path/errorfile.err >> $iacs_path/mail.lst
   echo "Error found"
   
   mailx -s "DWHSE side : ERRORS in Hayes & Jarvis booking load into iacs datawarehouse" basds@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/HJload/mail.lst 
   mailx -s "DWHSE side : ERRORS in Hayes & Jarvis booking load into iacs datawarehouse" jon.hollamby@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/HJload/mail.lst 
   
fi
   

