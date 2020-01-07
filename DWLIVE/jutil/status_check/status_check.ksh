#!/usr/bin/ksh
#set -x

# **********************************************************************
# *                    APPLICATION STATUS CHECKER                      *
# **********************************************************************
# * Parameters                                                         *
# *                                                                    *
# * 1 - Application Name - This MUST match the 8 character application *
# *                        key in the application table                *
# * 2 - Log Directory    - Final Resting Place of any logs created by  *
# *                        the status check                            *
# **********************************************************************

. /home/dw/bin/set_oracle_variables.ksh

# *******************************************************************
# *                    DECLARE VARIABLES                            *
# *******************************************************************

app_name=$1
log_dir=$2
stat_path=/home/dw/DWLIVE/jutil/status_check
jutil_pass=`cat /home/dw/DWLIVE/passwords/jutil.txt`

today=`date +%Y%b%d`
time_now=`date +%H%M%S`
status_output=${log_dir}/${app_name}_${today}.log

# *******************************************************************
# *                      PROGRAM START                              *
# *******************************************************************

echo "Starting Application Status Check for ${app_name} at `date +%H:%M:%S`" > ${status_output}

#Getting Utl_File directory from Application Registry for chosen Application
sqlplus -s jutil/${jutil_pass}<<End_Of_File1|read a
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select 
parameter_value
from application_registry
where application_key = '${app_name}'
and parameter_key = 'UtlFileDir';
exit
End_Of_File1
utl_file_dir=${a}

#Getting Duration to Hold Logs for from Application Registry for chosen Application
sqlplus -s jutil/${jutil_pass}<<End_Of_File2|read a
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select 
parameter_value
from application_registry
where application_key = '${app_name}'
and parameter_key = 'HoldLogsFor';
exit
End_Of_File2
hold_for=${a}

# Output variables to log
echo "Variables defined as" >> ${status_output}
echo "Application Key      : ${app_name}" >> ${status_output}
echo "Final Logs Directory : ${log_dir}" >> ${status_output}
echo "Utl_File Directory   : ${utl_file_dir}" >> ${status_output}
echo "Keep Logs for        : ${hold_for}" >> ${status_output}
echo "jutil password       : ${jutil_pass}" >> ${status_output}

# Run Status Checker
echo "execute p_Application_Status_Check.Check_Application_Status('${app_name}')"|sqlplus -s jutil/${jutil_pass}

# Move Log file to final directory
new_file=${log_dir}/${app_name}${today}_${time_now}.log
mv ${utl_file_dir}/${app_name}*.txt ${new_file}

# Delete any old logs file
echo "about to remove files from ${aces_log} more than ${hold_for} days old" >> ${status_output}
cd ${log_dir}
for delfiles in `find ${log_dir} -name "*" -mtime +${hold_for}`
do
  echo "deleting ${delfiles} from backup area (more than ${hold_for} days old)" >> ${status_output}
  rm ${delfiles}
done

echo "Finished Application Status Check for ${app_name} at `date +%H:%M:%S`" >> ${status_output}



