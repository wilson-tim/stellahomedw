
#!/usr/bin/ksh

# set -x

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Shell Name: fch_sqlload.ksh                                                                      #
#                                                                                                  #
# Purpose                                                                                          #
# -------                                                                                          #
# Loads a file using SQL*Loader into the database.                                                 #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #
#  History                                                                                         #
#  -------                                                                                         #
#                                                                                                  #
# Date      By         Description                                                                 #
# --------  ---------- --------------------------------------------------------------------------- #
# 10/12/02 A.James     Initial version.                                                            #
#                      N.B.This shell is based on the shell used for loading data in the Retail    #
#                          Retail load (shell 'retailprofit.ksh').                                 #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Input Parameters                                                                                 #
# ----------------                                                                                 #
#                                                                                                  #
# $1 Schema name for loading data.                                                                 #
# $2 Password for schema.                                                                          #
# $3 Name (including path) of file to be loaded.                                                   #
# $4 Name (including path) of control file.                                                        #
# $5 Name (including path) of output log file.                                                     #
# $6 Name (including path) of output bad file.                                                     #
#                                                                                                  #
#                                                                                                  #
# Option Flags                                                                                     #
# ------------                                                                                     #
#                                                                                                  #
# Example Runs                                                                                     #
# ------------                                                                                     #
#  fch_sqload.ksh dw dw_passwd /data/data1 /home/data1.ctrl /data/data1.log /data/data1.bad        #
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
# The following function echoes the date and time in a particular format and any parameters passed #
# to this function. It can be used to output log messages with a consistent date and time format.  #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

function report
{
  echo `date +%Y/%m/%d---%H:%M:%S` $*     # Format is YYYY/MM/DD---HH24:MI:SS
}

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
#                                    Body of shell follows.                                        #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# Standard log message at start of script.
report ": Starting script ${0} to load the ${source_file} file from the remote host ${remote_host}.\n"
report ": Parameters passed: ${*}.\n"

load_user="${1}"
load_passwd="${2}"
load_file="${3}"
control_file="${4}"
log_file="${5}"
bad_file="${6}"

#
# Load the file.
#

report ": Attempting to load the ${source_file} file.\n"

sqlldr ${load_user}/${load_passwd} errors=1000000  \
control=${control_file} \
data=${load_file} \
log=${log_file} \
bad=${bad_file}

exit_code=${?}

#
# Handle exit codes from SQL*LOADER.
# 0 = Success
# 1 = Failed with syntax or ORACLE errors.
# 2 = Warning (some rows rejected, or some discarded or load discontinued).
# 3 = Fatal error (Operating system errors such as file open/close and malloc).
#
case "${exit_code}" in
0) echo "SQL*Loader execution successful"
   exit_code=0
   ;;
1) echo "SQL*Loader execution exited with a FAILURE, see logfile ${log_file}";;
2) echo "SQL*Loader execution finished with WARNINGs. Check warnings in logfile ${log_file}"
   exit_code=0
   ;;
3) echo "SQL*Loader execution encountered a FATAL ERROR, see logfile ${log_file}" ;;
*) echo "unknown return code";;
esac

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
#                                          End of shell                                            #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

if [[ "${exit_code}" -eq 0 ]] then
   # Final standard log messages if script completed successfully.
   report ": 'SQL*Load' completed successfully.\n"
   report ": Script '${0}' finished....\n"

else
   # Final standard log messages if script failed.
   report ": 'SQL*Load' failed.\n"
   report ": Script '${0}' aborted....\n"
fi

exit ${exit_code}

