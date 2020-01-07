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
dbase_id=DWLIVE
export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:.
export ORACLE_HOME=/oracle
export ORACLE_TERM=vt220
export ORACLE_SID=DWLN10
export ORACLE_DOC=/oracle/odoc
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$ORACLE_HOME/bin:$PATH
export GMS_QUERY_FILE=/dev/rvsd_gms
export GMS_NODE_LIST=/oracle/dbs/gms.nodes
export GMS_HC_SOCKET=/tmp/serv.hc
export GMS_LOG_DIR=/oracle/rdbms/log/gms.log

today_d=`date +%Y%b%d`
#today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`
#

home="/home/dw/"$dbase_id                   # Home path
lg_path=$home"/logs/"                       # Path for SQL*Load Log, Discard and Bad files
f_log_path=$lg_path"hotelpayments"          # Path for output from jobs
iacs_path=$home"/hotelpayments/extract"     # Path for the hotel payments sql source files
zip_path="/data/hotelpayments/export"       # Path for zip files


echo "IACS Extract started" >  $f_log_path/iacsextract$today_d.log 

date >> $f_log_path/iacsextract$today_d.log 

echo "Moving old files to Backup" >>  $f_log_path/iacsextract$today_d.log

mv -f /data/hotelpayments/export/*.* /data/hotelpayments/export/backup

echo "Extracting reference and booking data " >>  $f_log_path/iacsextract$today_d.log 

sqlplus  iacs/iacs @$iacs_path/iacscall >> $f_log_path/iacsextract$today_d.log 

# Now zip these files and move ref and booking file into backup dir
cd $zip_path
for filename in `ls *.w99`
do
  zip $filename.zip $filename
  mv -f $filename backup
done
cd $iacs_path

date >> $f_log_path/iacsextract$today_d.log 
echo "FINISHED IACSEXTRACT!" >> $f_log_path/iacsextract$today_d.log &
