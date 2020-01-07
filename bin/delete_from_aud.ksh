#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
sqlplus -s system/t1pple <<EOF
prompt Deleting DW
delete from sys.aud$ where userid = 'DW' and 'LOGOFF$TIME' is not null;
commit;
prompt Deleting DATAW
delete from sys.aud$ where userid = 'DATAW' and 'LOGOFF$TIME' is not null;
commit;
prompt Deleting Month Old
delete from sys.aud$ where timestamp# < sysdate - 31;
commit;
EOF
