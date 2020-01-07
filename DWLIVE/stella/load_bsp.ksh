#!/bin/ksh
#set -x

####################################################################################################
#                                                                                                  #
# LOAD_bsp.KSH  Load and integrate script for loading and integrating late prices                  #
#                                                                                                  #
####################################################################################################
# Change                                                                                           #
# ------                                                                                           #
#                                                                                                  #
# Date          Who               Description                                                      #
# ----------    --------------    -----------                                                      #
# 04/08/2003    Leigh             Created script                                                   #
#                                 in log file if none present                                      #
#                                                                                                  #
####################################################################################################
# Input Parameters                                                                                 #
# ----------------                                                                                 #
# Option Flags                                                                                     #
# ------------                                                                                     #
#  r   Step to restart job from if required. If no -r flag supplied then it defaults to 00 which   #
#      means run the whole job.                                                                    # 
#                                                                                                  #
####################################################################################################
# NOTES                                                                                            #
# The xargs command is used throughout this script to prevent parameter list too long errors       #
# occuring when issue commands such as ls and rm                                                   #
####################################################################################################

function report
{
   echo `date +%Y/%m/%d---%H:%M:%S` $*
}

appdir="/home/dw/DWLIVE/stella"
datadir="/data/stella/bspfiles"
datasourcedir="/data/stella"
today_d=`date +%Y%b%d`
today_d=`echo $today_d | sed /.*/y/ADFJMNOS/adfjmnos/`
PASSWD=`cat /home/dw/DWLIVE/passwords/stella.txt`
PASSWDB=`cat /home/dw/DWLIVE/passwords/stellabatch.txt`
error_log="${checkdir}/log.lst"
error_log2="${checkdir}/emptylog.lst"
user_mail_list="${appdir}/bspusermail.lst"
appsupport_list="${appdir}/appsupportmail.lst"
backupdir="${datasourcedir}/backup"
mailmessage="${appdir}/mail_message.txt"
f_log_path="/home/dw/DWLIVE/logs/stella"
stellabakdir="/data/stella/backup"
date1=`date +%Y%m`
date2=`date +%Y%b%d`

echo $PASSWD 
report ": Parameters passed: ${*}.\n"

report "--------------------------------------------------------------------------"
report ">>>>>> Stella bsp Load load_bsp.ksh"
report "--------------------------------------------------------------------------"

# Setting variables
report "Setting variables"
. /home/dw/bin/set_oracle_variables.ksh

echo $ORACLE_SID
report "Checking input params"
START_STEP_NO=${START_STEP_NO:=00}

while getopts d:r: value
do

  case $value in
    r) START_STEP_NO=${OPTARG}
            ;;
    \?) echo "${0}: unknown option ${OPTARG}"
           exit 2
           ;;
  esac

done
echo "start at step " $START_STEP_NO

export START_STEP_NO

report "FTPing files from source server"
step_no=10
report "Step ${step_no}\n"
if [[ "${step_no}" -ge "${START_STEP_NO}" ]] then
  echo "not written yet"
else
  report "Step ${step_no} bypassed.\n"
fi


step_no=20
report "Step ${step_no}\n"
if [[ "${step_no}" -ge "${START_STEP_NO}" ]] then
  report "List of contents of data file directory before actual processing starts"

  cd ${datadir}
  ls *.* | xargs -n 1 echo 

  report "Run the stored proc that runs the java program to load the files into database"
  sqlplus -s stella/$PASSWD  @$appdir/run_bsp_load.sql > $appdir/run_bsp_load.lst


  report "Show output from java program"
  cat ${appdir}/run_bsp_load.lst

  report "Completed load of data"

  report "Logfile used for run was "   
  logfile=`grep "Lf#" ${appdir}/run_bsp_load.lst | cut -f2 -d#` 
  echo ${logfile}

  report "Clearing out old error file"
  rm ${appdir}/bsp_error.err

  report "Finding errors to email"
  grep "Fail" ${logfile} >> ${appdir}/bsp_error.err 
  grep "Error " ${logfile} >> ${appdir}/bsp_error.err
  grep "CRITICAL"  ${appdir}/run_bsp_load.lst  >> ${appdir}/bsp_error.err
  grep "SEVERE" ${logfile} >> ${appdir}/bsp_error.err
  grep "WARNING" ${logfile} >> ${appdir}/bsp_error.err
  echo " " >> ${appdir}/bsp_error.err
  grep "INFO :" ${logfile} >> ${appdir}/bsp_error.err
else
  report "Step ${step_no} bypassed.\n"
fi

step_no=50
report "Step ${step_no}\n"
if [[ "${step_no}" -ge "${START_STEP_NO}" ]] then
  # -s tests that size > 0 bytes
  if [ -s ${appdir}/bsp_error.err ]
  then
    echo "error found"
    echo >>  ${appdir}/bsp_error.err
#  Only send error line  , else full log is very big and sends empty mail
    echo "Logfile:${logfile}" >> ${appdir}/bsp_error.err
    cat ${user_mail_list} ${appsupport_list}|while read users
    do
      echo ${users}
      mailx -s "Details of STELLA bsp load warnings/errors encountered `hostname`  on "$today_d" " ${users} < ${appdir}/bsp_error.err
    done
 
  fi
else
  report "Step ${step_no} bypassed.\n"
fi




report "END OF PROGRAM" 
exit 0
