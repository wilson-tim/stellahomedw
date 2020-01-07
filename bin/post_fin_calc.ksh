#!/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
cd /home/dw/rob/fstat_results/
echo "@fcalc_status.sql W05"|sqlplus -s dw/dbp
echo "@fcalc_status.sql S06"|sqlplus -s dw/dbp
