#!/bin/ksh
#
# Set Variables
export ORACLE_HOME=/oracle
export ORACLE_SID=DWLN9

# Connect to database and flush shared pool
/oracle/bin/svrmgrl<<EOF
connect internal
select TO_CHAR(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') from DUAL;
alter system flush shared_pool;
exit
EOF
