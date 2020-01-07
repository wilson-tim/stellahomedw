#!/usr/bin/ksh
#set -x

# *******************************************************************
# *                  PROCESS CHECKING ROUTINE                       *
# *******************************************************************
# *                                                                 *
# * This shell script is called with three parameters,              *
# * Parameter 1 - Time in seconds between each loop                 *
# * Parameter 2 - Number of times round loop                        *
# * Parameter 3 - User name used in process call                    *
# *                                                                 *
# * Example Call                                                    *
# * process_check.ksh 900 20 dw                                     *
# * This will perform the checks, wait for 900 seconds (15 minutes) *
# * and run for a total of 5 hours (15 minutes * 20), it will check *
# * the processes running against user dw                           *
# *                                                                 *
# *******************************************************************

. /home/dw/bin/set_oracle_variables.ksh

# *******************************************************************
# *                    DECLARE VARIABLES                            *
# *******************************************************************

sleep_time=$1
num_loops=$2
username=$3

app_dir=/home/dw/DWLIVE/process_check
log_dir=/home/dw/DWLIVE/logs/process_check

# *******************************************************************
# *                      PROGRAM START                              *
# *******************************************************************

# Get Date Information from Oracle
sqlplus -s dw/dbp<<Rob_S|read a b
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select 
to_char(sysdate,'Dy'),
to_char(trunc(sysdate),'yyyymondd')
from dual;
exit
Rob_S
export day_stamp=${a}
export date_stamp=${b}

Create empty log files
process_file=${log_dir}/process_check.${day_stamp}_${date_stamp}
session_file=${log_dir}/session_check.${day_stamp}_${date_stamp}

>${process_file}
>${session_file}

#Beginning  19:30  loop at 15 minute intervals until 00:30
 (( k=0 ))

while [[ k -le ${num_loops} ]]
do

  sqlplus -s dw/dbp<<Rob_S2|read a 
  set pagesize 0
  set echo off
  set heading off
  set feedback off
  set verify off
  select 
  to_char(sysdate,'hh24:mi:ss')
  from dual;
  exit
Rob_S2
  export time_stamp=${a}

  echo k=${k}      Time=${time_stamp}>>${process_file}
  ps -fu${username}|sort -k5|grep -v sort|grep -v "sleep"|grep -v "ps -fudw"|grep -v process_check>>${process_file}
  echo "__/\__/\__/\__">>${process_file}
  echo "  ">>${process_file}

  echo k=${k}      Time=${time_stamp}>>${session_file}
  sessions>>${session_file}
  echo "__/\__/\__/\__">>${session_file}
  echo "  ">>${session_file}

  (( k = k+1 ))
  sleep ${sleep_time}
done

cd ${log_dir}
for delfiles in `find ${log_dir} -name "*" -mtime +30`
do
  rm ${delfiles}
done



