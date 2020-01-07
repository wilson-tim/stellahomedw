#
#

# . /home/dw/bin/set_oracle_variables.ksh 




sqlplus  -s tlinkw/austere@dwl   <<ENDOFSQL  


execute zcron; 

exit; 

ENDOFSQL 
 



