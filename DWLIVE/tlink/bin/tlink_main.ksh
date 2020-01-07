
#!/usr/bin/ksh

# set -x

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Shell Name: tlink_main.ksh (renamed std_main.ksh)                                                #
#                                                                                                  #
# Purpose                                                                                          #
# -------                                                                                          #
# Template main script for doing the actual job.                                                   #
#                                                                                                  #
# Notes:                                                                                           #
# 1. Contains examples of steps to do various tasks, e.g. run a SQL*PLUS module.                   #
# 2. Each example step contains code to bypas it by checking the variable "START_STEP_NO". To make #
#    a step mandatory just comment out the bypass check (leave the code in in case it needs to be  #
#    reinstated later).                                                                            #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#
#  History                                                                                         #
#  -------                                                                                         #
#                                                                                                  #
# Date      By         Description                                                                 #
# --------  ---------- --------------------------------------------------------------------------- #
# dd/mm/yy  author     Initial Version.                                                            #
# 29/06/09  COA        Modified to send a file to BO server to indicate success.
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Input Parameters                                                                                 #
# ----------------                                                                                 #
#                                                                                                  #
# Option Flags                                                                                     #
# ------------                                                                                     #
#                                                                                                  #
# Example Runs                                                                                     #
# ------------                                                                                     #
# ${BIN}/tlink_main.ksh >${LOGS}/tlink${RUNDATE}.log 2>${LOGS}/tlink${RUNDATE}.err                   #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# To Do                                                                                            #
# -----                                                                                            #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Run standard shell scripts.                                                                      #
#                                                                                                  #
# N.B. These are always run in every shell script even if they have been run by the calling shell. #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

. /home/dw/bin/set_oracle_variables.ksh              # Sets up Oracle environment.
. /home/dw/bin/set_java_variables.ksh                # Sets up Java environment.


# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# The following function echoes the date and time in a particular format and any parameters passed #
# to this function. It can be used to output log messages with a consistent date and time format.  #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

function report
{
  echo "`date +%Y/%m/%d---%H:%M:%S` $*"
}

function getJavaParameter
{
#
# Function takes the input parameters and wraps double quotes around them to form a
# standard java parameter.

  echo "\"${*}\""

}

# Standard log message at start of script.
report ": Starting script ${0} to tlink.\n"
report ": Parameters passed: ${*}.\n"

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
#                                    Body of shell follows.                                        #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #




#
# Step nn
# ------
# Example of a step to run a SQL*PLUS module with parameters. Replace with own description.
#
# N.B. As a standard, "sql_debug_mode" should always be the last parameter in the list.
#

step_no=00
report "Step ${step_no}\n"

WAIT_FOR_JOB_NAME=TL_S_Staging
#TIMEOUT_SECONDS=10800
# Increase wait for slo-dwlive
TIMEOUT_SECONDS=34200
APPLICATION_KEY=TLINKW

#
# Bypass step if "START_STEP_NO" greater than step number.
#
report " step no '$step_no' and '$START_STEP_NO'"

if [[ "${step_no}" -ge "${START_STEP_NO}" ]] then

report " Before start sql plus to call sql script .................."
   sqlplus -s ${USER}/${PASSWD} @${BIN}/tlink_run.sql ${WAIT_FOR_JOB_NAME} ${TIMEOUT_SECONDS} ${APPLICATION_KEY} ${sql_debug_mode}
   
exit_code=${?}
report " Tlnik SQL script compelted and exit code is '$exit_code' and   '${?}'"

   if [[ "${exit_code}" -ne 0 ]] then
      report ": tlink failed...\n"
      report ": Script '${0}' aborted....\n"
      exit_code=1
   else
      report ": ftp '${TLINK_HOST}' '${TLINK_USER}' '${TLINK_LOCAL_DIRECTORY}' '${TLINK_FILENAME}'"
      FTP_OUTPUT=`ftp -vni << EOF
      open ${TLINK_HOST}
      user ${TLINK_USER} ${TLINK_PASSWD}
      lcd  ${TLINK_LOCAL_DIRECTORY}
      put ${TLINK_FILENAME} ${TLINK_FILENAME}
      quit
      EOF`
      echo $FTP_OUTPUT | grep -i "Transfer complete"
      report "Output from FTP: \n${FTP_OUTPUT}\n"
   fi
else
   report "Step ${step_no} bypassed.\n"
fi




# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
#                                          End of shell                                            #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

if [[ "${exit_code}" -eq 0 ]] then
   # Final standard log messages if script completed successfully.
   report ": tlink completed successfully.\n"
   report ": Script '${0}' finished....\n"
sleep 1200
      report ": ftp '${TLINK_HOST}' '${TLINK_USER}' '${TLINK_LOCAL_DIRECTORY}' '${TLINK_FILENAME}'"
      FTP_OUTPUT=`ftp -vni << EOF
      open ${TLINK_HOST}
      user ${TLINK_USER} ${TLINK_PASSWD}
      lcd  ${TLINK_LOCAL_DIRECTORY}
      put ${TLINK_FILENAME} ${TLINK_FILENAME}"2"
      quit
      EOF`
      echo $FTP_OUTPUT | grep -i "Transfer complete"
      report "Output from FTP: \n${FTP_OUTPUT}\n"
sleep 1200
      report ": ftp '${TLINK_HOST}' '${TLINK_USER}' '${TLINK_LOCAL_DIRECTORY}' '${TLINK_FILENAME}'"
      FTP_OUTPUT=`ftp -vni << EOF
      open ${TLINK_HOST}
      user ${TLINK_USER} ${TLINK_PASSWD}
      lcd  ${TLINK_LOCAL_DIRECTORY}
      put ${TLINK_FILENAME} ${TLINK_FILENAME}"3"
      quit
      EOF`
      echo $FTP_OUTPUT | grep -i "Transfer complete"
      report "Output from FTP: \n${FTP_OUTPUT}\n"

else
   # Final standard log messages if script failed.
   report ": tlink failed.\n"
   report ": Script '${0}' aborted....\n"
fi

exit ${exit_code}


