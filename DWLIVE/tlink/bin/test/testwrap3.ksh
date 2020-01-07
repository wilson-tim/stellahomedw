#
#

THISPROC=$$ 

echo "THISPROC = $THISPROC" 


. /home/dw/DWLIVE/tlink/bin/test/testshell.ksh &  

SHELL=$! 

echo "SHELL = $SHELL" 



sleep 10


kill -s HUP $SHELL 

break









 



