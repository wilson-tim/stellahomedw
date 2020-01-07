#
#

. /home/dw/bin/set_oracle_variables.ksh 



sqlplus  -s tlinkw/austere@dwl   <<ENDOFSQL  


execute tlink_load_dummy_toms_pit2_l(201206); 

commit; 


-- execute tlink_load_dummy_toms_pit2(201202);

commit; 

exit; 

ENDOFSQL 
 



