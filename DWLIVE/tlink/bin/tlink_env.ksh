
#!/usr/bin/ksh

# set -x

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Shell Name: xxxxxxxxxx_env.ksh                                                                   #
#                                                                                                  #
# Purpose                                                                                          #
# -------                                                                                          #
# Sets up the standard environment, e.g. initialises common variables.                             #
#                                                                                                  #
# Notes:                                                                                           #
# 1. Must be run in current shell to ensure exported variables are available to sub-shells.        #
# 2. The variables in this shell are the most LIKELIEST to be required. They are not necessarily   #
#    a complete list.                                                                              #
# 3. Replace 'xxxxxxxxxx' with actual values for the job being set up.                             #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#
#  History                                                                                         #
#  -------                                                                                         #
#                                                                                                  #
# Date      By              Description                                                            #
# --------  --------------- -----------------------------------------------------------------------#
# 09/11/05  S.R.Williams    Initial Version.                                                       #
# 29/06/09  COA             Modified to include ftp parameters for succes file ind to BO 
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
#  . xxxxxxxxxx_env.ksh                                                                            #
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
# Set up environment variables.
#

DBASE=DWLIVE                                # The database identifier.
export DBASE

FCH_BIN=/home/dw/bin                        # Location of common shells used at First Choice
export FCH_BIN

FCH_SQL=/home/dw/bin                        # Location of common SQL*PLUS modules used at First Choice
export FCH_SQL

BIN=/home/dw/DWLIVE/tlink/bin               # Location of application executables, e.g. shells SQL*PLUS modules.
export BIN

LOGS=/home/dw/DWLIVE/logs/tlink             # Location of output logs.
export LOGS

TEMP=/data                                  # Location for temporary files
export TEMP

DATA_ARCHIVE=/data/tlink_archive            # Location for archiving the data files.
export DATA_ARCHIVE

USER=TLINKW                                 # ORACLE schema to connect to.
export USER

PASSWD=`cat /home/dw/DWLIVE/tlink/bin/tlink_password.txt`     # File containing password of ORACLE schema to connect to.
export PASSWD

TLINK_HOST=10.0.160.45                      # Host of TLINK  BO
export TLINK_HOST

TLINK_USER=oracle                           # ftp userid for TLINK BO
export TLINK_USER

TLINK_PASSWD=0r4cl3
export TLINK_PASSWD

TLINK_FILENAME=tlink_load_finished          # file status fo TLINK BO
export TLINK_FILENAME

TLINK_LOCAL_DIRECTORY=/home/dw/DWLIVE/tlink/bin # location of file statis TLINK BO
export TLINK_LOCAL_DIRECTORY



RUNDATE=`date +%Y%m%d%H%M%S`                # Uniquely identifies the log and error files.
export RUNDATE

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Setup common parameters used in java mail program.                                               #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

LIST_SEPARATOR=','                       # Separator used in in lists for mail.
export LIST_SEPARATOR

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# End of set up of java parameters.                                                                #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

