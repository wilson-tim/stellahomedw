#!/usr/bin/ksh
######################################################################################################
#
# PROGRAM:  iacs_analyse.ksh
#
# DATE        BY  DESCRIPTION
# ----        --  -----------
#
# 05/4/00     LA  Initial Version.
#
#
# script to analyse iacs schema tables
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


echo "IACS anal started" >  $f_log_path/iacsanal$today_d.log 

date >> $f_log_path/iacsanal$today_d.log 


sqlplus -s  iacs/iacs @$iacs_path/iacs_analyze >> $f_log_path/iacsanal$today_d.log 


date >> $f_log_path/iacsanal$today_d.log 
echo "FINISHED IACS_ANALYSE" >> $f_log_path/iacsanal$today_d.log &
