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


echo "IACS Extract started" >  $f_log_path/iacsextract$today_d.log 

date >> $f_log_path/iacsextract$today_d.log 

echo "Moving old files to Backup" >>  $f_log_path/iacsextract$today_d.log


echo "Extracting reference and booking data " >>  $f_log_path/iacsextract$today_d.log 


# Now zip these files and move ref and booking file into backup dir
cd $iacs_path

date >> $f_log_path/iacsextract$today_d.log 
echo "FINISHED IACSEXTRACT!" >> $f_log_path/iacsextract$today_d.log &
