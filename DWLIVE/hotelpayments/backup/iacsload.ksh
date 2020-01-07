#!/usr/bin/ksh
######################################################################################################
#
# PROGRAM:  iacsload.ksh
#
# DATE        BY  DESCRIPTION
# ----        --  -----------
#
# 2/12/99     LA  Initial Version.
#
#
# script to run iacs hotel payments data extracts from dw/dataw tables
# into iacs schema#
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
today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`
#

home="/home/dw/"$dbase_id                   # Home path
lg_path=$home"/logs/"                       # Path for SQL*Load Log, Discard and Bad files
f_log_path=$lg_path"hotelpayments"          # Path for output from jobs
iacs_path=$home"/hotelpayments/extract"     # Path for the hotel payments sql source files

echo "IACS Load started" >  $f_log_path/iacsload$today_d.log 

date >> $f_log_path/iacsload$today_d.log 
echo "about to start locations..." >> $f_log_path/iacsload$today_d.log 
sqlplus  dw/dbp @$iacs_path/locationext >> $f_log_path/iacsload$today_d.log 

date >> $f_log_path/iacsload$today_d.log 
echo "about to start properties..." >> $f_log_path/iacsload$today_d.log 
sqlplus  dw/dbp @$iacs_path/propertyext >> $f_log_path/iacsload$today_d.log 

date >> $f_log_path/iacsload$today_d.log 
echo "about to start bookings...." >> $f_log_path/iacsload$today_d.log 
sqlplus  dw/dbp @$iacs_path/bkgext >> $f_log_path/iacsload$today_d.log 

date >> $f_log_path/iacsload$today_d.log 
echo "FINISHED IACSLOAD!" >> $f_log_path/iacsload$today_d.log &
