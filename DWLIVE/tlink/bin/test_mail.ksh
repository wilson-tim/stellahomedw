

#!/usr/bin/ksh

# set -x

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Shell Name: tlink_shell.ksh (modified std_shell.ksh)                                             #
#                                                                                                  #
# Purpose                                                                                          #
# -------                                                                                          #
# Enter description of job.                                                                        #
#                                                                                                  #
# Notes:                                                                                           #
# 1. This is a template script to be used as the basis for new jobs.                               #
# 2. It includes a simple restart facility to start the main script at a particular step.          #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Process                                                                                          #
# -------                                                                                          #
# The structure of the standard shell script for jobs is as follows:                               #
#                                                                                                  #
# 1. Comments and history.                                                                         #
#                                                                                                  #
# 2. Job initialisation.                                                                           #
#    -  Run standard scripts, e.g. to set up the Oracle environment.                               #
#    -  Standard shell functions, e.g. function to set up Java parameters.                         #
#    -  Turn SQL and Java debugging on or off (default off).                                       #
#    -  Call the shell to initialise the common runtime environment for this application.          #
#    -  Initialise variables unique to the job.                                                    #
#    -  Functions specific to the job.                                                             #
#    -  Custom Java parameters for the job.                                                        #
#                                                                                                  #
# 3. Standard job processing.                                                                      #
#    - Put standard beginning messages into the mail message. This will be sent to interested      #
#      parties at the end of the job to show the outcome of the job. Example messages are the      #
#      name of the host and parameters used in the run.                                            #
#    - Handle option flags, if any. It is expected that at least the restart flag will be used.    #
#    - Call the script(s) that carry out the actual job. Note that the standard output and error   #
#      of the script(s) are written to files which are sent with the mail message at the end.      #
#    - Perform any housekeeping, e.g. remove log files from previous runs that are more than 30    #
#       days old.                                                                                  #
#    - Complete the mail message and send to interested parties. This includes indicating success  #
#      or failure, attaching the output log and error files to the mail message, sending the mail, #
#      and removing the temporary mail message.                                                    #
#                                                                                                  #
# 4. Job end.                                                                                      #
#    Exit the shell with an exit code of success or failure as required.                           #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
#  History                                                                                         #
#  -------                                                                                         #
#                                                                                                  #
# Date      By         Description                                                                 #
# --------  ---------- --------------------------------------------------------------------------- #
# dd/mm/yy  name       Initial Version.                                                            #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Input Parameters                                                                                 #
# ----------------                                                                                 #
# $1 - Enter description of parameter.                                                             #
#                                                                                                  #
# Option Flags                                                                                     #
# ------------                                                                                     #
# x - Enter description of each option flag.                                                       #
# r - Restart flag plus restart step number.                                                       #
#                                                                                                  #
# Example Runs                                                                                     #
# ------------                                                                                     #
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
#                                  Job initialisation follows.                                     #
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
# Standard shell functions follow.                                                                 #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

function getJavaParameter
{
#
# Function takes the input parameters and wraps double quotes around them to form a
# standard java parameter.

  echo "\"${*}\""

}

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Turn SQL and Java debugging on or off.                                                           #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

#
# To turn SQL debugging on set the following variable to 'ON'.
#
  sql_debug_mode=OFF
# sql_debug_mode=ON
export sql_debug_mode

#
# To turn java debugging on set the following variable to true (off set it to false).
#
  java_debug_mode=false
# java_debug_mode=true
java_debug_mode=`getJavaParameter ${java_debug_mode}`
export java_debug_mode


# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Run script to set up custom environment for the job. A shell script is used as it may be re-used #
# in another job.                                                                                  #
# N.B. Must be run in current shell to make variables available for all sub-shells.                #
#                                                                                                  #
# Replace 'xxxxxxxxx_env.ksh' below with full path and name of custom environment file to be run.  #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

. /home/dw/DWLIVE/tlink/bin/tlink_env.ksh


# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Set up custom variables and defaults, e.g. the mail users file.                                  #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

#
# Following variable contains the name of the file that has the mail addresses of the users who
# should receive the log and error files from this run, e.g. the users in the Support team.
#
RUN_MAILUSERS_FILE=/home/dw/DWLIVE/tlink/bin/tlink.mailusers
export RUN_MAILUSERS_FILE

MAIL_MSG_FILE=/home/dw/DWLIVE/tlink/bin/tlink.message.txt
export MAIL_MSG_FILE



# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Custom shell functions follow.                                                                   #
#                                                                                                  #
# N.B. These may include references to variables that have been set up earlier.                    #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

#                                                                                               
# The following functions echo the date and time in a particular format and any parameters passed
# to the function. It can be used to output log messages with a consistent date and time format.  
#

function mailreport
{
  echo "$*" >> ${TEMP}/tlink${RUNDATE}.mail    # Outputs all parameters to a runtime mail file.
}

function logreport
{
  echo "`date +%Y/%m/%d---%H:%M:%S` $*" >> ${LOGS}/tlink${RUNDATE}.log       # Format is YYYY/MM/DD---HH24:MI:SS

}



# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Setup custom parameters used in java programs.                                                   #
#                                                                                                  #
# N.B. These are just examples.                                                                    #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #




# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# End of set up of java parameters.                                                                #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #


# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
#                                  End of job initialisation.                                      #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #



# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
#                                    Body of shell follows.                                        #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

#
# Step 10
# ------
#
# Put standard messages at beginning of temporary mail file.
# 
mail_subject="TEST EMAIL please respond to Tim Lloyd  - "${ORACLE_SID}
mailreport "\n`date +%d/%0m/%Y`\n----------\n" > ${TEMP}/tlink${RUNDATE}.mail
mailreport "TEST EMAIL for Niel Alobaidi\n" >> ${TEMP}/tlink${RUNDATE}.mail
mailreport "'${0}' script run on machine:" >> ${TEMP}/tlink${RUNDATE}.mail
hostname >> ${TEMP}/tlink${RUNDATE}.mail

#
# Set up attachment file list.
#

#attach_file_list="\"${LOGS}/tlink${RUNDATE}.log${LIST_SEPARATOR}${LOGS}/tlink${RUNDATE}.err\""
attach_file_list="\"${LOGS}/tlink20070806040000.log${LIST_SEPARATOR}${LOGS}/tlink20070806040000.err\""

#
# Set attachment list to standard java parameter.
#

attach_file_list=`getJavaParameter ${attach_file_list}`
#
# Set up debug option flag.
#
if [[ "${java_debug_mode}" = true ]] then
   java_debug_flag=-d
fi

${FCH_BIN}/fch_mail.ksh ${java_debug_flag} "\"${mail_subject}"\" "${TEMP}/tlink${RUNDATE}.mail" ${LIST_SEPARATOR} ${RUN_MAILUSERS_FILE} ${attach_file_list}


