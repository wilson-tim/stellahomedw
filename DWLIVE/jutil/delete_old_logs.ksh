#!/bin/ksh
#set -x

#######################################################################
#                                                                     #
# DELETE_OLD_LOGS.KSH  Delete logs from jutil.application_log where   #
#                      the event date is older than 60 days           #
#                      (second parameter passed to Stored Procedure   #
#                                                                     #
#######################################################################
# Change                                                              #
# ------                                                              #
#                                                                     #
# Date          Who     Description                                   #
# ----          ---     -----------                                   #
# 18/06/2003    JAD     Initial Version                               #
#                                                                     #
#######################################################################
# Parameters passed to stored procedures                              #
# --------------------------------------                              #
#                                                                     #
# Parameter 1 - records deleted before commit is issued               #
# Parameter 2 - number of days old logs are before they are deleted   #
# Parameter 3 - path for output file (uses utl file)                  #
# Parameter 4 - filename for output file                              #
#######################################################################


#######################################################################
#              Set Variables used with Shell                          #
#######################################################################

app_path='/home/dw/DWLIVE/jutil'
log_path='/home/dw/DWLIVE/logs/jutil'
output_path='/home/dw/SQL_Output'
output_file='delete_applog.txt'
school_output_file='delete_school_applog.txt'
commit_point=1000
days_old=60
school_days_old=3

password=`cat ${app_path}/jutil_pass.txt`
error_temp=${app_path}/temperrs.txt
error_file=${app_path}/delerrs.txt
mail_list=${app_path}/maillist.txt
school_mail_list=${app_path}/school_maillist.txt
today_d=`date +%d/%m/%Y-%H%M`

. /home/dw/bin/set_oracle_variables.ksh


#######################################################################
#                    Start of Shell Script                            #
#######################################################################


echo "Deletion of old log files started " ${today_d}
echo ""

echo "execute Delete_Old_logs('${commit_point}','${days_old}','${output_path}','${output_file}')"|sqlplus -s jutil/${password}
#sqlplus -s jutil/${password} |&
#print -p "spool ${error_temp}"
#print -p "set serveroutput on size 1000000
#begin
#  Delete_Old_Logs('${commit_point}','${days_old}','${output_path}','${output_file}');
#end;"
#print -p '/'
#print -p "exit"

# The following section needs to be added so the shell script waits for the
# anonymous block above to finish
#while read -p LINE         # Get the co-process output
#do
#  print - ${LINE}
#done


#grep for errors in log file, output to error file
grep "Error" ${output_path}/${output_file} > ${error_file}
grep "Error" ${error_temp} >> ${error_file}
  
if [ -s ${error_file} ]
then
  echo "Errors have occurred - mailing to following people"
  echo ""

  echo "" >> ${error_file}
  echo "These errors were encountered during deletion of old logs " >> ${error_file}
  echo "" >> ${error_file}

  for users in `cat ${mail_list}`
  do
    echo ${users}
    mailx -s "Errors encountered during deletion of old logs" ${users} < ${error_file}
  done
else
  echo "No Errors encountered during run"
  echo ""

  for users in `cat ${mail_list}`
  do
    mailx -s "jutil.application_log deletion process on `hostname`" ${users} < ${output_path}/${output_file}
  done
  
fi

rm ${error_file}
rm ${error_temp}


# New section to remove school logs every three days - temp resolve for excess data
echo "Delete_Old_School_Logs('${commit_point}','${school_days_old}','${output_path}','${school_output_file}')|sqlplus -s jutil/${password}
 
#sqlplus -s jutil/${password} |&
#print -p "spool ${error_temp}"
#print -p "set serveroutput on size 1000000
#begin
#  Delete_Old_School_Logs('${commit_point}','${school_days_old}','${output_path}','${school_output_file}');
#end;"
#print -p '/'
#print -p "exit"

# The following section needs to be added so the shell script waits for the
# anonymous block above to finish
#while read -p LINE         # Get the co-process output
#do
#  print - ${LINE}
#done


#grep for errors in log file, output to error file
grep "Error" ${output_path}/${school_output_file} > ${error_file}
grep "Error" ${error_temp} >> ${error_file}
  
if [ -s ${error_file} ]
then
  echo "Errors have occurred - mailing to following people"
  echo ""

  echo "" >> ${error_file}
  echo "These errors were encountered during deletion of old school logs " >> ${error_file}
  echo "" >> ${error_file}

  for users in `cat ${school_mail_list}`
  do
    echo ${users}
    mailx -s "Errors encountered during deletion of old logs" ${users} < ${error_file}
  done
else
  echo "No Errors encountered during run"
  echo ""

  for users in `cat ${school_mail_list}`
  do
    mailx -s "jutil.application_log deletion process on `hostname` for SCHOOLS" ${users} < ${output_path}/${school_output_file}
  done
  
fi

rm ${error_file}
rm ${error_temp}

exit
