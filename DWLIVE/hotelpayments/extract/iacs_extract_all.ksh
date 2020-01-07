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
# export directory is removed and recreated everytime it runs livetransfer.rfs 
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

echo "IACS Extract started" >  $f_log_path/iacsextract_all$today_d.log 


date >> $f_log_path/iacsextract_all$today_d.log 

# There won't be any old files as export directory is removed and recreated after each transfer
echo "Moving old files to Backup" >>  $f_log_path/iacsextract_all$today_d.log
chmod 777 /data/hotelpayments/*
mv -f /data/hotelpayments/export/*.* /data/hotelpayments/backup

echo "Extracting reference and booking data " >>  $f_log_path/iacsextract_all$today_d.log 

sqlplus  iacs/iacs @$iacs_path/iacs_extract_all >> $f_log_path/iacsextract_all$today_d.log 

# Now zip these files and move ref and booking file into backup dir
cd $zip_path
#mv *20*_r* *20*_r.w99*
for filename in `ls *20*_*`
do
  zip $filename.zip $filename
#  mv -f $filename ../backup/.
done
cd $iacs_path

 # remove old deason files from Cyprus, they only want to start in w02
rm /data/hotelpayments/export/CYP*s01*
rm /data/hotelpayments/export/CYP*s02*
rm /data/hotelpayments/export/CYP*w01*
 # Take backup of all zip files
   cp -f /data/hotelpayments/export/*.zip /data/hotelpayments/backup

date >> $f_log_path/iacsextract_all$today_d.log 
echo "FINISHED IACSEXTRACT!" >> $f_log_path/iacsextract_all$today_d.log &
