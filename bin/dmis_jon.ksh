#!/usr/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
#Rob_S   21 May 2004
#NEW DMIS
#This is dmis_poller.ksh
#Called by a cronline with a season parameter like:- 
#/home/dw/DWLIVE/integration/dmis_check.ksh s04  1> /home/dw/DWLIVE/logs/dmis/dmis_check_s04.log 2>&1
#With one cronline per season

#set -x

#Some initial definitions: But first make sure that directories named here exist.
#Below defines a useful function called report which takes none - or any number 
#of parameters
#__/\__/\__/\__SET UP PARAMETERS, PATHS ETC

function report
{
  echo `date +%Y/%m/%d---%H:%M:%S` $*
}

#--\__/R\_||_/S\__/--
export season=$1
#__/\__/\__/\__/\__
typeset -u seas
seas=${season}
export seas
#seas is the upper case version.

typeset -l today
export today_d=`date +%Y%b%d`
export today=${today_d}
export x_today=`date +%d-%b-%Y`
#__/\__/\__
export load_path="/home/dw/DWLIVE/load/otop/"
export exist_lst="/home/dw/DWLIVE/load/otop/otop_sl_existing.lst"
export log_path="/home/dw/DWLIVE/logs/dmis/"
export control_path="/home/dw/DWLIVE/integration/"
export chekrun="/home/dw/DWLIVE/integration/chekrun/"
export data_path="/data/dmis/"
export fin_path="/home/dw/DWLIVE/fin_calc/"
#
#export xmis_passwd="`cat /home/dw/DWLIVE/passwords/anite_test.txt`"
export xmis_passwd="`cat /home/dw/DWLIVE/passwords/cray.txt`"
#
export whouse_passwd="`cat /home/dw/DWLIVE/passwords/whouse.txt`"
#


#_/\__/\__CHECK WHETHER DMIS OR NORMAL INTEGRATION ARE RUNNING -  AND IF SO DROP OUT.
if [[ -a ${chekrun}dmis_run_checker.${season} ]] then
       echo "******************************************************************"
       echo "***** CANNOT START:  DMIS FOR ${seas}. ALREADY RUNNING*****"
       echo "******************************************************************"
       exit 0
fi 
#--=<\_/R\_>X<_/S\_/>=--
#Below we use Oracle to get the season's XMIS status via the monitor table.
sqlplus -s dw/dbp<<Rob_S|read xstat
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select status from monitor m
where 1=1
and m.season_year=to_char(to_date(substr('${seas}',2,2),'rr'),'yyyy')
and m.season_type=substr('${seas}',1,1)
and m.context='XMIS'
and m.start_date=(select max(k.start_date) 
from monitor k 
where k.season_year= to_char(to_date(substr('${seas}',2,2),'rr'),'yyyy')
and k.season_type= substr('${seas}',1,1)
and k.context='XMIS')
;
exit
Rob_S
#--=<\_/R\_>X<_/S\_/>=--
if [[ ${xstat} = "STARTED" ]] then
echo "**********************************************************************"
echo "XMIS INTEGRATION FOR ${seas} STILL RUNNING. CANNOT START DMIS"
 echo "**********************************************************************"
 exit 0
fi 
#--=<\_/R\_>X<_/S\_/>=--
#
echo "NEITHER DMIS NOR XMIS RUNNING FOR ${seas} SO CONTINUE PROCESS"


# CREATE DMIS_RUN_CHECKER FILE (INDICATES THAT DMIS IS RUNNING FOR SEASON
>${chekrun}dmis_run_checker.${season}

# GET BUILT FILE FROM ANITE TO SEE IF FILES HAVE CHANGED SINCE LAST RUN
cd ${data_path}
echo "open cray" >${data_path}get_${season}.ctl
#echo "open 10.20.0.29" >${data_path}get_${season}.ctl
echo "user data_w ${xmis_passwd}" >>${data_path}get_${season}.ctl
echo "case" >> ${data_path}get_${season}.ctl 
echo "nmap \$1.\$2;\$3  \$1.\$2" >> ${data_path}get_${season}.ctl 
echo "cd otop_pcd:" >> ${data_path}get_${season}.ctl
echo "get built.${season};0" >> ${data_path}get_${season}.ctl
echo "quit" >> ${data_path}get_${season}.ctl

#This control file is then used to actually get the files. The control file is then purged.
ftp -nvi<${data_path}get_${season}.ctl
#rm ${data_path}get_${season}.ctl

# SEE IF SEQUENCE NUMBER OF BUILT FILE IS DIFFERENT FROM LAST ONE.
cat ${data_path}last_built.${season}| read last_seq
cat ${data_path}built.${season}|read seq
export seq
export last_seq
if [[ ${seq} = ${last_seq} ]] 
then
    echo "No new built file at Anite: hence don't run for season ${season}"
    # Need to remove dmis_run_checker file so future runs can occur
    rm ${chekrun}dmis_run_checker.${season}
    exit 0
fi

# IF WE HAVE GOT TO THIS POINT THEN WE HAVE
# FILES TO PROCESS -  SO WE CAN LAUNCH DMIS
echo Launch dmis 

# LOG START TIME IN SEASONAL LOG FILE
echo ">>>>> Data Warehouse Hourly Market Update  for ${season} (dmis)   Started " `date` >> /home/dw/DWLIVE/logs/dmis/dw_dmis_control.${season}_log

# BEGIN MAIN DMIS PROCESS
/home/dw/DWLIVE/integration/int_k_dmis_jon.ksh  1> /home/dw/DWLIVE/logs/dmis/int_dmis_${seq}.${season}_log1  \
                                                 2> /home/dw/DWLIVE/logs/dmis/int_dmis_${seq}.${season}_log2

# LOG END TIME IN SEASONAL LOG FILE
echo ">>>>> Data Warehouse Market Update for ${season} (DMIS)   Ended   " `date` >> /home/dw/DWLIVE/logs/dmis/dw_dmis_control.${season}_log
echo "-------------------------------------------------------------------------------------------------" >> /home/dw/DWLIVE/logs/dmis/dw_dmis_control.${season}_log


