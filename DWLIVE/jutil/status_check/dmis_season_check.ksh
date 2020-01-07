#!/usr/bin/ksh
#set -x

# **********************************************************************
# *                    DMIS CHECKING SEASON UPDATE                     *
# **********************************************************************

. /home/dw/bin/set_oracle_variables.ksh

# *******************************************************************
# *                    DECLARE VARIABLES                            *
# *******************************************************************

jutil_pass=`cat /home/dw/DWLIVE/passwords/jutil.txt`


# *******************************************************************
# *                      PROGRAM START                              *
# *******************************************************************

echo "Starting Dmis Season Check at `date +%H:%M:%S`"

# Run Season Check
echo "execute p_App_Stat_Procedures.Set_Dmis_Season"|sqlplus -s jutil/${jutil_pass}

echo "Finished Dmis Season Check at `date +%H:%M:%S`"



