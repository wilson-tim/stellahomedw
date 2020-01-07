#!/usr/bin/ksh
#_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
#Leigh sep02
#_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
. /home/dw/bin/set_oracle_variables.ksh
PASSWD=`cat /home/dw/DWLIVE/passwords/stella.txt`
#_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\
echo "about to analyse entire stella schema"
echo "Execute dbms_utility.analyze_schema('STELLA','COMPUTE');"|sqlplus -s stella/$PASSWD
#_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\_/\

