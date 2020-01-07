#
#

. /home/dw/bin/set_oracle_variables.ksh 

 


. /home/dw/DWLIVE/tlink/bin/test/testshell.ksh &  

SHELL=$! 

echo "SHELL = $SHELL" 

THISPROC=$$ 

echo "THISPROC = $THISPROC" 


TIMER="0"  
RUNNING="true" 

while [[ $RUNNING = "true" ]]  
do 


sleep 1

TIMER=`expr $TIMER + 1` 
 
echo "TIMER = $TIMER" 


if [[ $TIMER = "10" ]] 
then  

# echo "TIMER = $TIMER" 
 
kill  $SHELL

break 

RUNNING="false"  

fi 

done 













 



