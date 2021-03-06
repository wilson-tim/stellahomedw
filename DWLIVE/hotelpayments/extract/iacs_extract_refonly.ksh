#!/usr/bin/ksh
######################################################################################################
#
# PROGRAM:  iacsextract.ksh
#
# DATE        BY  DESCRIPTION
# ----        --  -----------
#
# 3/12/99     JR  Initial Version.
#
#
# script to create reference and booking file/files from iacs tables
#
#######################################################################################################
#
# Set oracle variables
#
. /home/dw/bin/set_oracle_variables.ksh
#
today_d=`date +%Y%b%d`
#today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`
#
dbase_id=DWLIVE
home="/home/dw/"$dbase_id                   # Home path
lg_path=$home"/logs/"                       # Path for SQL*Load Log, Discard and Bad files
f_log_path=$lg_path"hotelpayments"          # Path for output from jobs
iacs_path=$home"/hotelpayments/extract"     # Path for the hotel payments sql source files
zip_path="/data/hotelpayments/export"       # Path for zip files


echo "IACS Extract started" >  $f_log_path/iacsextract_refonly$today_d.log 


date >> $f_log_path/iacsextract_refonly$today_d.log 

echo "Moving old files to Backup" >>  $f_log_path/iacsextract_refonly$today_d.log
chmod 777 /data/hotelpayments/*
mv -f /data/hotelpayments/export/*_r.* /data/hotelpayments/backup

echo "Extracting reference and booking data " >>  $f_log_path/iacsextract_refonly$today_d.log 

sqlplus  iacs/iacs @$iacs_path/iacs_extract_refonly >> $f_log_path/iacsextract_refonly$today_d.log 

# Now zip these files and move ref and booking file into backup dir
cd $zip_path
for filename in `ls *20*_r*`
do
#  mv $filename $filename.w99
  zip $filename.zip $filename
  mv -f $filename ../backup/.
done
cd $iacs_path

date >> $f_log_path/iacsextract_refonly$today_d.log 
echo "FINISHED IACSEXTRACT!" >> $f_log_path/iacsextract_refonly$today_d.log &
