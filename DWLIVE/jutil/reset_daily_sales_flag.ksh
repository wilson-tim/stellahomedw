#!/usr/bin/ksh
#set -x

# **********************************************************************
# *                    RESET DAILY SALES FLAG                          *
# **********************************************************************

. /home/dw/bin/set_oracle_variables.ksh

# *******************************************************************
# *                    DECLARE VARIABLES                            *
# *******************************************************************

jutil_pass=`cat /home/dw/DWLIVE/passwords/jutil.txt`

# *******************************************************************
# *                      PROGRAM START                              *
# *******************************************************************


# Run Procedure
echo "execute sp_daily_sales_flag"|sqlplus -s jutil/${jutil_pass}



