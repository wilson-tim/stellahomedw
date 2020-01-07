#!/bin/ksh
#set -x

#######################################################################
#                                                                     #
# ERROR_LOGS.KSH  Extract all entries in jutil.application_log that   #
#                 have an event_level or event_type of a predefined   #
#                 set                                                 #
#######################################################################
# Change                                                              #
# ------                                                              #
#                                                                     #
# Date          Who     Description                                   #
# ----          ---     -----------                                   #
# 18/06/2003    JAD     Initial Version                               #
#                                                                     #
#######################################################################


#######################################################################
#              Set Variables used with Shell                          #
#######################################################################

#set paths required
app_path='/home/dw/DWLIVE/jutil'
log_path='/home/dw/DWLIVE/logs/jutil'
output_path='/home/dw/SQL_Output'
output_file='log_errors.csv'

#set variables used within shell
today_d=`date +%d/%m/%Y`
mail_list=${app_path}/log_maillist.txt
password=`cat ${app_path}/jutil_pass.txt`
email_body=${app_path}/mailbody.txt
error_file=${app_path}/temperr.txt
tempfile=${log_path}/temp.txt

# the separator value is based on the ascii character set value
# 9 is the value for a tab
# 44 is the value for a comma
file_separator='44' 


. /home/dw/bin/set_oracle_variables.ksh


#######################################################################
#                 Start of Shell Script                               #
#######################################################################


#Remove old existence of file
rm -f ${output_path}/${output_file}

sqlplus -s jutil/${password} |&
print -p "spool ${error_file}"
print -p "set serveroutput on size 1000000
begin
  Check_Log_for_Errors('${output_path}','${output_file}','${file_separator}');
end;"
print -p '/'
print -p "exit"

# The following section needs to be added so the shell script waits for the
# anonymous block above to finish
while read -p LINE         # Get the co-process output
do
  print - ${LINE} 
done

# This code only works in 8i
#echo "\n \n connect jutil/${password}@dwt \n execute Check_Log_for_Errors('${output_path}','${output_file}','${file_separator}');\n exit\n" | svrmgrl

# count how many lines are in the file as there will always be at least one line
# due to the header row
echo `wc -l ${output_path}/${output_file}` > ${tempfile}
head -1 ${tempfile}|while read line_count dummy_col
do
  echo "******* Processes created ${line_count} rows *******"
  echo "----------------------------------------------------"
  echo ""

  #have to move the value to different variable otherwise it gets wiped second time through loop
  hold_lc=${line_count}
done
rm -f ${tempfile}

if [ ${hold_lc} -gt 1 ]
then
  # Report has generated some output - needs to be emailed to a list of people
  echo "Problems have been found - emailing errors as CSV file to a list of users"

  #Send emails to mailing list using Java program
  /home/dw/bin/fch_mail.ksh "\"Errors have been located in Application Log table dated ${today_d} on `hostname` \"" "${email_body}" "," "${mail_list}" "${output_path}/${output_file}"

else
  # Nothing to report - send no email but log in file
  echo "Nothing to report"
fi

exit
