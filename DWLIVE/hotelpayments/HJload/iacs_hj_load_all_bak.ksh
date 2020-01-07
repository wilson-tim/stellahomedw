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
#
# Script to load into datawarehouse-iacs tables from xml files provided by Hayes & Jarvis
# Step 1 : Fetch files from remote H&J server using http , this will create .xml files into /data/hotelpayments/SMLFILES
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
#today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`
#
dbase_id=DWLIVE
home="/home/dw/"$dbase_id                   # Home path
lg_path=$home"/logs/"    
f_log_path=$lg_path"hotelpayments"          # Path for output from jobs
iacs_path=$home"/hotelpayments/HJload"      # Path for the hotel payments sql source files

zip_path="/data/hotelpayments/XMLFILES/"    # Path for zip files

echo "IACS Hayes&Jarvis Load started" >  $f_log_path/iacshjload_all$today_d.log 

date >> $f_log_path/iacshjload_all$today_d.log 

#echo "Moving old files to Backup" >>  $f_log_path/iacshjload_all$today_d.log
#chmod 777 /data/hotelpayments/XMLFILES/*
#mv -f /data/hotelpayments/XMLFILES/*.* /data/hotelpayments/XMLFILES/backup

########################################################################################################################
# Step 1 : Fetch files from remote H&J server using http , this will create .xml files into /data/hotelpayments/SMLFILES
########################################################################################################################
#it calls TMS - database name hjtmsmis user name iacs/password ip addres is 10.8.253.60
echo "Fetching reference and booking data file from H&J server " >>  $f_log_path/iacshjload_all$today_d.log 
java http2file hjintranet 80 /sql/?sql=execute+hj_location?root=root /data/hotelpayments/XMLFILES/location.xml >>  $f_log_path/iacshjload_all$today_d.log
java http2file hjintranet 80 /sql/?sql=execute+hj_property?root=root /data/hotelpayments/XMLFILES/property.xml >>  $f_log_path/iacshjload_all$today_d.log
java http2file hjintranet 80 /sql/?sql=execute+hj_propertycode?root=root /data/hotelpayments/XMLFILES/propertycode.xml >>  $f_log_path/iacshjload_all$today_d.log
java -mx256m http2file hjintranet 80 /sql/?sql=execute+hj_booking?root=root /data/hotelpayments/XMLFILES/booking.xml >>  $f_log_path/iacshjload_all$today_d.log
java -mx256m http2file hjintranet 80 /sql/?sql=execute+hj_bookingaccom?root=root /data/hotelpayments/XMLFILES/bookingaccom.xml >>  $f_log_path/iacshjload_all$today_d.log

#######################################################################################################################
# Step 2 : Reference and  Booking files will be loaded first into temp tables using Oracle PutXML
#######################################################################################################################
date >> $f_log_path/iacshjload_all$today_d.log 
echo "Loading Reference data into temporary tables " >>  $f_log_path/iacshjload_all$today_d.log 

java OracleXML putXML -user "iacs/iacs" -conn "jdbc:oracle:thin:@dwlive_en1:1521:dwl"  -commitBatch 10 -rowTag LOCATION -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/location.xml  temp_xml_location >>  $f_log_path/iacshjload_all$today_d.log
java OracleXML putXML -user "iacs/iacs" -conn "jdbc:oracle:thin:@dwlive_en1:1521:dwl"  -commitBatch 10 -rowTag PROPERTY -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/property.xml  temp_xml_property >>  $f_log_path/iacshjload_all$today_d.log
java OracleXML putXML -user "iacs/iacs" -conn "jdbc:oracle:thin:@dwlive_en1:1521:dwl"  -commitBatch 10 -rowTag OTOP_PROPERTY -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/propertycode.xml  temp_xml_otop_property >>  $f_log_path/iacshjload_all$today_d.log

date >> $f_log_path/iacshjload_all$today_d.log 
echo "Loading booking and bookingaccom data into temporary tables " >>  $f_log_path/iacshjload_all$today_d.log 

java -mx256m OracleXML putXML -user "iacs/iacs" -conn "jdbc:oracle:thin:@dwlive_en1:1521:dwl"  -commitBatch 10 -rowTag BOOKING -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/booking.xml  temp_xml_booking >>  $f_log_path/iacshjload_all$today_d.log
java -mx256m OracleXML putXML -user "iacs/iacs" -conn "jdbc:oracle:thin:@dwlive_en1:1521:dwl"  -commitBatch 10 -rowTag BOOKINGACCOM -dateFormat "dd/MM/yyyy" -fileName /data/hotelpayments/XMLFILES/bookingaccom.xml  temp_xml_booking_accom >>  $f_log_path/iacshjload_all$today_d.log
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
#mv *20*_r* *20*_r.w99*
for filename in `ls *.xml`
do
  zip xmlbkup$today_d.zip $filename  >>  $f_log_path/iacshjload_all$today_d.log
#  mv -f $filename ../backup/.
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
# Take backup of all zip files
#  cp -f /data/hotelpayments/export/*.zip /data/hotelpayments/backup


 ##############################################################################################
# if Error in xml load then  send log file along with no. of records in iacs_general_error table to support team 
 ##############################################################################################


 #cat $iacs_path/mail.lst

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
 and severity > 1;
exit
!
   
   # -s tests that  size > 0 bytes
   if [ -s $iacs_path/errorfile.err ]
   then
      echo "Batch Program run on machine:" > $iacs_path/mail.lst
      hostname >> $iacs_path/mail.lst
      cat  $f_log_path/iacshjload_all$today_d.log  >>  $iacs_path/mail.lst
      echo ' Following records from iacs_general_error table are in error :' >> $iacs_path/mail.lst
      cat $iacs_path/errorfile.err >> $iacs_path/mail.lst
      echo "Error found"
   
 mailx -s "DWHSE side : Hayes & Jarvis booking load into iacs datawarehouse" basds@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/HJload/mail.lst 
 mailx -s "DWHSE side : Hayes & Jarvis booking load into iacs datawarehouse" jon.hollamby@firstchoice.co.uk < /home/dw/DWLIVE/hotelpayments/HJload/mail.lst 
   
   fi
   

