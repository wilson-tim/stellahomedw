#!/usr/bin/ksh
#This is killer.ksh. To run it type killer.ksh and the parent process number
#as a parameter. eg something like killer.ksh 9999. It will then find and 
#kill the parent and the child oracle process.
#
      ps -fudw | grep $1 | grep oracle | grep -v grep > plist
      if [ -s plist ]
      then
         #
         # Read the the file to get the PID of the Oracle child process
         #
         cat plist |
         while read dummy oracle_child dummy dummy
         do
            #
            # Kill the parent process and the Oracle child process
            #
            echo "Found Oracle child process "$oracle_child
            echo "*** Killing $1 and  "$oracle_child" ***"
            kill $1
            kill -9 $oracle_child
            rm plist
         done
      else
         echo "Error - could not find child of parent" 
      fi
exit 0

