
#!/usr/bin/ksh

# set -x

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# Shell Name: retail_store_and_zip.ksh                                                             #
#                                                                                                  #
# Purpose                                                                                          #
# -------                                                                                          #
#  Compresses and archives the FX files.                                                           #
#                                                                                                  #
#  Notes:                                                                                          #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #
#  History                                                                                         #
#  -------                                                                                         #
#                                                                                                  #
# Date      By         Description                                                                 #
# --------  ---------- --------------------------------------------------------------------------- #
# ??/??/??  R.Solomon  Initial version.                                                            #
# 17/03/03  A.James    Modified to compress and archive any file in the directory. Required for    #
#                      version of FX that uses the 'ZIP' files (which can have any name).          #
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
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

# ------------------------------------------------------------------------------------------------ #
#                                                                                                  #
# To Do                                                                                            #
# -----                                                                                            #
#                                                                                                  #
# ------------------------------------------------------------------------------------------------ #

. /home/dw/bin/set_oracle_variables.ksh

sqlplus -s dw/dbp <<END | while read variable1 variable2
set heading off
set feedback off
select to_char(sysdate -19, 'YYYYMM'), to_char(sysdate -19,'YYYYMMDD') from dual;
exit
END
do
  if [ ${variable1:-none} != "none" -a ${variable2:-none} != "none" ]
  then
    archive_directory=/data/retail_archive/$variable1
    if [ ! -d $archive_directory ]
    then
      mkdir $archive_directory
      echo Made $archive_directory
    fi
    if [ -d $archive_directory ]
    then
      if [ ! -f $archive_directory/retail_$variable2.tar.Z ]
      then
        tar cvf $archive_directory/retail_$variable2.tar /data/retail_archive/*${variable2}*
        compress $archive_directory/retail_$variable2.tar
        rm /data/retail_archive/*${variable2}*
      else
        echo "You are running for a duplicate day. Aborting......"
      fi
    fi
  fi
done
