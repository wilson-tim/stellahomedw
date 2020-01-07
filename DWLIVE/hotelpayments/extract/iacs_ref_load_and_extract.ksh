#!/usr/bin/ksh
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
######################################################################################################
# AND THEN EXTRACTS THE REFERERENCE DATA AT THE END
# AND THEN EXTRACTS THE REFERERENCE DATA AT THE END
# AND THEN EXTRACTS THE REFERERENCE DATA AT THE END
# AND THEN EXTRACTS THE REFERERENCE DATA AT THE END
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
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
# THIS PART VERSION DOES NOT DO THE BOOKING DATA, JUST LOCATION AND PROPERTY
#######################################################################################################
#
# Set oracle variables
#
. /home/dw/bin/set_oracle_variables.ksh
#
today_d=`date +%Y%b%d`
today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`
#
dbase_id=DWLIVE
home="/home/dw/"$dbase_id                   # Home path
lg_path=$home"/logs/"                       # Path for SQL*Load Log, Discard and Bad files
f_log_path=$lg_path"hotelpayments"          # Path for output from jobs
iacs_path=$home"/hotelpayments/extract"     # Path for the hotel payments sql source files
chmod 777 /data/hotelpayments/*
echo "IACS Load started" >  $f_log_path/iacspropload$today_d.log 

date >> $f_log_path/iacspropload$today_d.log 
echo "about to start locations..." >> $f_log_path/iacspropload$today_d.log 
echo "IACS Load started" >  $f_log_path/iacpropsload$today_d.log 
echo "about to start locations..." >> $f_log_path/iacspropload$today_d.log 
sqlplus  dw/dbp @$iacs_path/locationload >> $f_log_path/iacspropload$today_d.log 

date >> $f_log_path/iacspropload$today_d.log 
echo "about to start properties..." >> $f_log_path/iacspropload$today_d.log 
sqlplus  dw/dbp @$iacs_path/propertyload >> $f_log_path/iacspropload$today_d.log 

date >> $f_log_path/iacspropload$today_d.log 
echo "FINISHED IACSPROPLOAD!" >> $f_log_path/iacspropload$today_d.log &

# now run the extract part

$iacs_path/iacs_extract_refonly.ksh 
