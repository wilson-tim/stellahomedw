#!/bin/ksh
################################################################################
# PUTLIVE.KSH
#
# DESCRIPTION
#  This script copies the supplied file to DWLIVE directories on nodes specified
#  in the .dwnodes file in the /DWLIVE directory of the current node.  
#
# Created by Anil Goindi on 3rd April 1998AD (DB CONSULTING)
################################################################################

################################################################################
# DEFINE CONSTANTS 
################################################################################
dwlive_path="/home/dw/DWLIVE"
dwnodes_file=$dwlive_path"/.dwnodes"
##dwlive_path="/home/dw/agoindi"
##dwnodes_file="/home/dw/DWLIVE/.dwnodes"
backup_dir="old"
putlive_ftp_ini="putlive_ftp.ini"
putlive_ftp_log="putlive_ftp.log"
dir_check_file="dir_check.txt"
tmp_file1="tmp1.fil"
tmp_file2="tmp2.fil"
################################################################################
# SCRIPT START 
################################################################################
if [[ $1 = ? ]] then
   echo "*******************************************************************"
   echo "* Enter the file you wish to copy from a directory within the     *"
   echo "* DWDEV environment to the DWLIVE environment.                    *"
   echo "* Your current directory must be a subdirectory of DWDEV.         *" 
   echo "*                                                                 *" 
   echo "* Eg. To to putlive from /home/dw/DWDEV/fruit/apple.txt you       *"
   echo "* change directory to /home/dw/DWDEV/fruit and enter:             *"
   echo "* putlive.ksh apple.txt                                           *"
   echo "* The file will be copied to /home/dw/DWLIVE/fruit/apple.txt      *" 
   echo "* on the relevant nodes having saved the previous version to      *" 
   echo "* /home/dw/DWLIVE/fruit/old/apple.txt                             *" 
   echo "*******************************************************************" 
   exit
fi

if [[ $1 = "" ]] then
   echo "**** NO FILE SPECIFIED - PLEASE ENTER A VALID FILE TO COPY ****"
   exit
fi

# Use grep to determine if a valid filename has been entered
grep dummy_string $1 2> grep.err
if [[ -s "grep.err" ]] then
   # File has error data
   cat "grep.err"
   rm "grep.err"
   echo "**************** COPY ABORTED ****************" 
   exit
fi
rm "grep.err"

# Get path of file to copy 
pwd | read current_path 

# Disable copying FROM DWLIVE directories
echo $current_path > $dir_check_file
grep -q DWDEV $dir_check_file
grep_status=$?
if [[ $grep_status -ne 0 ]] then
   echo "**************************************************"
   echo "****** YOU ARE NOT IN THE DWDEV ENVIRONMENT ******"
   echo "****** ONLY COPYING FROM DWDEV IS PERMITTED ******"
   echo "****************** COPY ABORTED ******************"
   echo "**************************************************" 
   rm $dir_check_file
   exit
else
   echo "****************************************************"
   echo "**** YOU ARE COPYING FROM THE DWDEV ENVIRONMENT ****"
   echo "************ TO THE DWLIVE ENVIRONMENTS ************"
   echo "****************************************************" 
fi
rm $dir_check_file

# Get path to copy to (ie DWDEV directory to DWLIVE in pwd path - $current_path)
echo $current_path > $tmp_file1 
sed "s/DWDEV/DWLIVE/g" $tmp_file1 > $tmp_file2
cat $tmp_file2 | read end_path                            # end_path variable holds path to copy file to 
rm $tmp_file1 $tmp_file2

# Copy file to node(s) specified in .dwnodes file
cat $dwnodes_file |
while read node_id db_inst 
do
   echo $node_id 
   if [[ $node_id = `hostname` ]] then
      echo "**** <ARCHIVE> Copy "$end_path"/"$1" to "$end_path"/"$backup_dir" ****"
      cp $end_path"/"$1 $end_path"/"$backup_dir"/"
      echo "**** Copy file "$1" to directory "$end_path" ****"
      cp $1 $end_path
   else 
      echo "**** <ARCHIVE> Copy "$end_path"/"$1" to "$end_path"/"$backup_dir" on node "$node_id" ****"
      #rsh $node_id cp $end_path"/"$1 $end_path"/"$backup_dir"/" # The rsh command is not reliable for multiple copies
                                                                 # eg. rsh cp, rsh cp. Only one rsh can be invoked within
                                                                 # loop. The rcp command is better and permits rcp..,rcp,,
                                                                 # (Anil Goindi) 
      rcp $node_id":"$end_path"/"$1 $node_id":"$end_path"/"$backup_dir"/"
      echo "Copy file "$1" to node "$node_id" and path "$end_path
      echo open $node_id                > $current_path"/"$putlive_ftp_ini
      echo user dw dwhouse             >> $current_path"/"$putlive_ftp_ini
      echo cd $end_path                >> $current_path"/"$putlive_ftp_ini
      echo put $1                      >> $current_path"/"$putlive_ftp_ini 
      echo quit                        >> $current_path"/"$putlive_ftp_ini
      ftp -n -v < $current_path"/"$putlive_ftp_ini >> $current_path"/"$putlive_ftp_log
      rm $current_path"/"$putlive_ftp_ini
      rm $current_path"/"$putlive_ftp_log             # Remove log but mask out line if required to see log for an ftp 
   fi
done
echo "******************* COPYING COMPLETE *******************"
echo
echo
echo "NOTE:"
echo "********************************************************"
echo "**** TO UNDO ANY CHANGES USE backout.ksh <filename> ****"
echo "***** FROM THE DIRECTORY IN THE DWDEV ENVIRONMENT ******"
echo "******* WHICH CONTAINS THE FILE YOU WISH TO UNDO *******"
echo "********************************************************"
