#!/usr/bin/ksh
# set -x
######################################################################################################
#
# set_java_variables.ksh   Script to call from any process that requires any additional java variables
#                          to those set by the 'set_oracle_variables.ksh' shell to be set.
#
# CALLS                       NONE
#
# PARAMETERS                  NONE
#
# ----------------------------------------------------------------------------------------------------
# CHANGE
# ------
#
# Date     Who                 Description
# -------- ------------------- ---------------------------------------------------------------------------------------
# 20/02/03 A.James             Initial creation.
# 14/04/03 A.James             XML 'jar' files added to CLASSPATH for HFC XML load.
# 14/05/03 A.James             First Choice mail 'jar' files added to CLASSPATH to enable mail.
# 06/06/03 A.James             1. The set up of the CLASSPATH for ORACLE moved to 'set_oracle_variables.ksh'. This 
#                                 means that only additional variables are added here. Also, PATH no longer modified
#                                 in here to avoid problem where java executables cannot be found. 
#                              2. Shell now called by the 'dw' profile so the java environment is only set in one
#                                 place.
# 30/06/03 A.James             1. '/java', 'java/classes' and 'java/bin' added to CLASSPATH as all future java 
#                                 packages, 'jar' files and historical classes will be run from these directories.
#
# 12/09/03 Jyoti R.             Added /apps/DWLIVE/java/bin/ftpservice.jar for FTP Program 
# 19/12/03 Dyanesh              Added jox jar file which convert xml to bean
# 23/04/07 AJ  Changed for migration project. Different versions of Oracle and java.
######################################################################################################

#
# Add additional java variables to CLASSPATH.
#

export CLASSPATH=$CLASSPATH:/apps/DWLIVE/java/bin/fchmail.jar:/apps/DWLIVE/java/bin/mail.jar:/apps/DWLIVE/java/bin/activation.jar:/apps/DWLIVE/java:/apps/DWLIVE/java/bin:/apps/DWLIVE/java/classes:/apps/DWLIVE/java/bin/ftpservice.jar:/apps/DWLIVE/java/bin/jox116.jar
export CLASSPATH=$CLASSPATH:/apps/DWL/java/bin/fchmail.jar:/apps/DWL/java/bin/mail.jar:/apps/DWL/java/bin/activation.jar:/apps/DWL/java:/apps/DWL/java/bin:/apps/DWL/java/classes:/apps/DWL/java/bin/ftpservice.jar:/apps/DWL/java/bin/jox116.jar
