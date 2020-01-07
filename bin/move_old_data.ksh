#!/bin/ksh

. /home/dw/bin/set_oracle_variables.ksh

sqlplus -s dw/dbp <<END | while read variable1 variable2
set heading off
set feedback off
select to_char(sysdate -2, 'YYYYMM'), to_char(sysdate -2,'YYYYmonDD') from dual;
exit
END
do
  if [ ${variable1:-none} != "none" -a ${variable2:-none} != "none" ]
  then
    archive_directory=/data/archive/$variable1
    if [ ! -d $archive_directory ]
    then
      mkdir $archive_directory
      echo Made $archive_directory
    fi
    if [ -d $archive_directory ]
    then
      if [ ! -f $archive_directory/o_$variable2.tar.Z ]
      then
        tar cvf $archive_directory/o_$variable2.tar /data/archive/*$variable2.[s,w]*
        compress $archive_directory/o_$variable2.tar
        rm /data/archive/*$variable2.[s,w]*
      else
        echo "You are running for a duplicate day. Aborting......"
      fi
    fi
  fi
done
