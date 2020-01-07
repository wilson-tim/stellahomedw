

#!/usr/bin/ksh

# set -x

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Shell Name: fch_restart.ksh                                                                      #
#                                                                                                  #
# Purpose                                                                                          #
# -------                                                                                          #
# Script that restarts all jobs that run as "daemons". These jobs are started manually and left to #
# run continuously. However, occasionally all the 'dw' processes are killed which result in these  #
# "daemons" also being killed. In this circumstance, this script needs to be run to restart these  #
# processes.                                                                                       #
#                                                                                                  #
# Notes:                                                                                           #
# 1.This script may be also be added to the 'inittab' job that is run on system boot-up.           #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#
#  History                                                                                         #
#  -------                                                                                         #
#                                                                                                  #
# Date      By         Description                                                                 #
# --------  ---------- --------------------------------------------------------------------------- #
# 17/04/04  A.James    Initial Version.                                                            #
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
# /home/dw/bin/fch_restart.ksh                                                                     #
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
#                                    Body of shell follows.                                        #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #


#
# Restart the Retail FX load process.
#

/home/dw/DWLIVE/retail/fx/bin/start_fx_retail.ksh


#
# Restart the HFC load process.
#

/home/dw/DWLIVE/hfc/bin/hfc_start.ksh

exit

