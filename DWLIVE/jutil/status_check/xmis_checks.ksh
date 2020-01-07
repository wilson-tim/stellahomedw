#!/usr/bin/ksh
#set -x

# **********************************************************************
# *                        XMIS STATUS CHECKER                         *
# **********************************************************************

. /home/dw/bin/set_oracle_variables.ksh

# *******************************************************************
# *                    DECLARE VARIABLES                            *
# *******************************************************************

stat_path=/home/dw/DWLIVE/jutil/status_check
log_dir=/home/dw/DWLIVE/logs/status_check/xmis
data_dir=/data/tourops

otop_log_dir=/home/dw/DWLIVE/logs/otop
output_file=/home/dw/john/test.txt
load_dir="/home/dw/DWLIVE/load/otop"

jutil_pass=`cat /home/dw/DWLIVE/passwords/jutil.txt`

today=`date +%Y%b%d`
typeset -l l_today
l_today=${today}

xmis_output=${log_dir}/xmis_${today}.log
seasons_file=/home/dw/DWLIVE/load/otop/otop_ls_season.lst
mkt_list=/home/dw/DWLIVE/load/otop/otop_l_mkt.lst
dummy_file=${log_dir}/res_lines.txt


hold_for=30
tolerance=100
files_final_status=GREEN
files_message='All OK'
load_final_status=GREEN
load_message='All OK'

# *******************************************************************
# *                      PROGRAM START                              *
# *******************************************************************

echo "Starting XMIS Checks at `date +%H:%M:%S`" > ${xmis_output}

# Get Date from Oracle to use as part of filename checks
sqlplus -s jutil/${jutil_pass}<<End_Of_File1|read a
set pagesize 0
set echo off
set heading off
set feedback off
set verify off
select 
to_char(sysdate,'yyyymondd')
from dual;
exit
End_Of_File1
datestamp=${a}

echo "Datestamp set to ${datestamp}" >> ${xmis_output}
#Loop on seasons file
cat ${seasons_file}|while read hold_season
do
  echo "Doing season ${hold_season}" >> ${xmis_output}
  
  # for each season we need to read through the mkt list of abbreviations and check that they also exist
  cat ${mkt_list}|while read mkt_abbrev
  do
    echo "Checking abbrev ${mkt_abbrev}" >> ${xmis_output}
    
    # Work out the filename for the current abbreviation
    file_name=${data_dir}/o_${mkt_abbrev}${datestamp}.${hold_season}
    
    # we now have the datestamp, season and abbreviation so we can check for the instance of the file
    if [[ ! -a ${file_name} ]] then
      echo "file does not exist" >> ${xmis_output}
      
      files_final_status=RED
      files_message='Missing Mkt Files'
    fi
    
    # now check that the number of lines in the o_res file matches the number loaded
    if [[ ${mkt_abbrev} = res ]] then
      # get number of lines in res file
      res_lines=`cat ${file_name} | wc -l`
      
      echo "Lines in ${file_name} = ${res_lines}" >> ${xmis_output}

      # get number of bookings loaded for season
      sqlplus -s jutil/${jutil_pass}<<End_Of_File2|read b
      set pagesize 0
      set echo off
      set heading off
      set feedback off
      set verify off
      select count(*)
      from booking b
      where b.season_type = UPPER(substr('${hold_season}',1,1))
      and b.season_year = to_char(to_date(substr('${hold_season}',2,2),'rr'),'yyyy')
      and b.amended_date = trunc(sysdate);
      exit
End_Of_File2
      bookings_loaded=${b}
      
      echo "Bookings Loaded = ${bookings_loaded}" >> ${xmis_output}
      
      # If lines in file don't match bookings loaded + tolerance level then flag accordingly
      if [[ ${res_lines} -gt "${bookings_loaded} + ${tolerance}" ]] then
        echo "Bookings loaded less than expected amount" >> ${xmis_output}
        load_final_status=RED
        load_message='Not All Data Loaded'
      fi
    fi
    
  done

done


rm ${output_file}
echo  ${otop_log_dir}/o_*_log*|xargs grep -i -n "Unable"|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
echo  ${otop_log_dir}/o_*_log*|xargs grep -i -n "file not found"|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
echo  ${otop_log_dir}/o_*_log*|xargs grep -i -n "No such file"|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
echo  ${otop_log_dir}/o_*_log*|xargs grep -i -n "value larger"|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
echo  ${otop_log_dir}/o_*_log*|xargs grep -n "ORA_"|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep -i -n enough ${otop_log_dir}/otop_*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep -i -n refuse ${otop_log_dir}/otop_*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep    -n Fail ${otop_log_dir}/otop_*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep -i -n abort ${otop_log_dir}/otop_*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep -i -n exceed ${otop_log_dir}/otop_*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep    -n ORA ${otop_log_dir}/otop_*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep -i -n Failed ${otop_log_dir}/ftp_*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep -i -n "Error" ${otop_log_dir}/otop_*|grep -v mem|grep -v "load error file if it exists"|grep -v timeschmod|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
grep -i -n "syntax" /home/dw/DWLIVE/logs/*log*|grep -v mem|grep -v ORA-00001|grep -v ORA-06512 > ${output_file}
if [ -s /home/dw/john/test.txt ] 
then
  logs_final_status=RED
  logs_message='Errors exist in logs'
else
  logs_final_status=GREEN
  logs_message='No errors exist in logs'
fi


# Set the final status so if no bad files still get GREEN status
bad_final_status=GREEN
bad_message='No bad files exist for mkt data'
cat ${load_dir}/otop_ls_season.lst|while read season
do

  cat ${load_dir}/otop_l_mkt.lst|while read abbrev
  do
    if [[ ${abbrev} != mem ]] then 
      if [[ -f  ${otop_log_dir}/o_${abbrev}_bad${l_today}.${season} ]] then
        # A bad file exists so set status accordingly
        bad_final_status=RED
        bad_message='Bad files exist for mkt data'
      fi
    fi  
  done
done


sqlplus -s dw/dbp<<Exit_Sql|read ora_date
  set pagesize 0
  set echo off
  set heading off
  set feedback off
  set verify off
  select to_char(trunc(sysdate),'yyyymondd') from dual;
  exit
Exit_Sql
empty_date=${ora_date}

rm ${otop_log_dir}/empty_load_tables.lst
>${otop_log_dir}/empty_load_tables.lst

find ${otop_log_dir} -name "o_???_log${l_today}.???"|sort|while read x
do
  grep -li " 0 rows successfully loaded" ${x}|cut -b27,28,29,30,31,36,37,38,39,40,41,42,43,44,45,46,47,48>>${otop_log_dir}/empty_load_tables.lst
done

# Create a file that lists empty load tables alongside the number of rows in data file
rm ${otop_log_dir}/empty_load_tables2.lst
cat ${otop_log_dir}/empty_load_tables.lst|while read x
do
  wc -l ${data_dir}/${x}*|grep -v total|grep -v otop >> ${otop_log_dir}/empty_load_tables2.lst
done

# Now cat through newly created file and flag as error if data has been rejected
empty_final_status=GREEN
empty_message='No errors in Load tables'
cat ${otop_log_dir}/empty_load_tables2.lst|while read empty_count empty_file 
do
  if [[ ${empty_count} -ne 0 ]] then
    empty_final_status=RED
    empty_message='Load tables empty with data in files'
  fi
done


echo "Final Status of Files Check is ${files_final_status}" >> ${xmis_output}
echo "Final Status of Load Check is ${load_final_status}" >> ${xmis_output}
echo "Final Status of Logs Check is {logs_final_status)" >> ${xmis_output}
echo "Final Status of Bad Files Check is ${bad_final_status}" >> ${xmis_output}
echo "Final Status of Empty Files Check is ${empty_final_status}" >> ${xmis_output}

# Now update the application_status table using the API in p_Application_Status_Check
echo "execute p_Application_Status_Check.Insert_App_Status_Unix('RES_LINE','${load_final_status}','${load_message}')"|sqlplus -s jutil/${jutil_pass}
echo "execute p_Application_Status_Check.Insert_App_Status_Unix('MKT_FILE','${files_final_status}','${files_message}')"|sqlplus -s jutil/${jutil_pass}
echo "execute p_Application_Status_Check.Insert_App_Status_Unix('XMIS_LOG','${logs_final_status}','${logs_message}')"|sqlplus -s jutil/${jutil_pass}
echo "execute p_Application_Status_Check.Insert_App_Status_Unix('XMIS_BAD','${bad_final_status}','${bad_message}')"|sqlplus -s jutil/${jutil_pass}
echo "execute p_Application_Status_Check.Insert_App_Status_Unix('XMIS_LDR','${empty_final_status}','${empty_message}')"|sqlplus -s jutil/${jutil_pass}

# Delete any old logs file
echo "about to remove files from ${log_dir} more than ${hold_for} days old" >> ${xmis_output}
cd ${log_dir}
for delfiles in `find ${log_dir} -name "*" -mtime +${hold_for}`
do
  echo "deleting ${delfiles} from log area (more than ${hold_for} days old)" >> ${xmis_output}
  rm ${delfiles}
done

echo "Finished XMIS Checks at `date +%H:%M:%S`" >> ${xmis_output}



