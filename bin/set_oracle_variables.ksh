#!/usr/bin/ksh
# set -x
######################################################################################################
#
# SET_ORACLE_VARIABLES.KSH   Script to be call from any process that requires the oracle variables
#                            to be set. This includes setting up the java environment for ORACLE.
#
# CALLS                       NONE
#
# PARAMETERS                  NONE
#
# ----------------------------------------------------------------------------------------------------
# CHANGE
# ------
#
# Date     Who Description
# -------- --- ---------------------------------------------------------------------------------------
# 25/07/00 DJH Initial creation.
# 06/02/03 AJ  Modified for correct path for java. Plus shell now called by the 'dw' profile so the
#              environment is only set in one place.
# 08/09/03 AJ  Changed to java 1.4.
# 23/04/07 AJ  Changed for migration project. Different versions of Oracle and java.
#
######################################################################################################
#
# Set variables
#
# Set PATH to include locations for java.
#

export JAVA_HOME=$ORACLE_HOME/jdk

#export JAVA_HOME=/usr/lib/sun/current

export PATH=$JAVA_HOME/jre/bin:$JAVA_HOME/bin:/usr/local/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:/bin:.

#
# Following variables are required for JNI on AIX (java 1.4).
#
export AIXTHREAD_SCOPE=S
export AIXTHREAD_MUTEX_DEBUG=OFF
export AIXTHREAD_RWLOCK_DEBUG=OFF
export AIXTHREAD_COND_DEBUG=OFF

export ORACLE_TERM=vt220
export ORACLE_SID=DWL
ORAENV_ASK='NO';. oraenv;ORAENV_ASK=''
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/lib32
export LIBPATH=$ORACLE_HOME/lib:$ORACLE_HOME/lib32
#
# Set CLASSPATH for java 1.4 and ORACLE java classes.
#

export CLASSPATH=$JAVA_HOME/jre/lib:$ORACLE_HOME/jlib:$ORACLE_HOME/lib/xsu12.jar:$ORACLE_HOME/lib/xmlparserv2.jar:$ORACLE_HOME/lib/xmlcomp.jar:$ORACLE_HOME/jdbc/lib/classes12.jar:$ORACLE_HOME/jdbc/lib/nls_charset12.jar:$ORACLE_HOME/lib/oraclexsql.jar:$ORACLE_HOME/lib/xsqlserializers.jar:$ORACLE_HOME/rdbms/jlib/xdb.jar
#
echo "PATH set to: ${PATH}"
 echo "CLASSPATH set to: ${CLASSPATH}"
