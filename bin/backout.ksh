#!/bin/ksh
################################################################################
# BACKOUT.KSH
#
# DESCRIPTION
#  This script copies the supplied file to DWLIVE directories on nodes specified
#  in the .dwnodes file in the /DWLIVE directory of the current node.  
#
# Created by Anil Goindi on 7th April 1998AD (DB CONSULTING)
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
grep_err="grep.err"
tmp_file1="tmp1.fil"
tmp_file2="tmp2.fil"
################################################################################
# SCRIPT START 
################################################################################
if [[ $1 = ? ]] then
   echo "*******************************************************************"
   echo "* Enter the file you wish to copy from a /old directory           *"
   echo "* within the DWLIVE environment.                                  *"
   echo "* Your current directory must be a subdirectory of DWDEV.         *"
   echo "*                                                                 *"
   echo "* Eg. To to backout /home/dw/DWLIVE/fruit/apple.txt you           *"
   echo "* change directory to /home/dw/DWDEV/fruit and enter:             *"
   echo "* backout.ksh apple.txt                                           *"
   echo "* The file will be copied from                                    *"
   echo "* /home/dw/DWLIVE/fruit/old/apple.txt on the relevant nodes       *"
   echo "* to /home/dw/DWLIVE/fruit/apple.txt overwriting the previous     *"
   echo "* version.                                                        *"
   echo "*******************************************************************"
   exit
fi

if [[ $1 = "" ]] then
   echo "**** NO FILE SPECIFIED - PLEASE ENTER A VALID FILE TO COPY ****"
   exit
fi

# Get path of file to copy
pwd | read current_path

# Disable copying FROM DWLIVE directories
echo $current_path > $dir_check_file
grep -q DWDEV $dir_check_file
grep_status=$?
if [[ $grep_status -ne 0 ]] then
   echo "**************************************************"
   echo "****** YOU ARE NOT IN THE DWDEV ENVIRONMENT ******"
   echo "****** ONLY BACKOUT FROM DWDEV IS PERMITTED ******"
   echo "****************** COPY ABORTED ******************"
   echo "**************************************************"
   rm $dir_check_file
   exit
fi
rm $dir_check_file

# Get path to copy to (ie DWDEV directory to DWLIVE in pwd path - $current_path)
echo $current_path > $tmp_file1
sed "s/DWDEV/DWLIVE/g" $tmp_file1 > $tmp_file2
cat $tmp_file2 | read end_path         # end_path variable holds path to copy file to
echo 
rm $tmp_file1 $tmp_file2

# Use grep to determine if a valid filename has been entered
grep dummy_string $end_path"/"$backup_dir"/"$1 2> $end_path"/"$backup_dir"/"grep_err
if [[ -s $end_path"/"$backup_dir"/"grep_err ]] then
   # File has error data
   cat $end_path"/"$backup_dir"/"grep_err 
   rm $end_path"/"$backup_dir"/"grep_err 
   echo "**************** BACKOUT ABORTED *****************" 
   exit
fi
rm $end_path"/"$backup_dir"/"grep_err

# Copy file to node(s) specified in .dwnodes file
cat $dwnodes_file |
while read node_id db_inst 
do
   echo $node_id 
   if [[ $node_id = `hostname` ]] then
      echo "**** <UNDO> Copy "$end_path"/"$backup_dir"/"$1" to "$end_path"/ ****"
      cp $end_path"/"$backup_dir"/"$1 $end_path"/"
   else 
      echo "**** <UNDO> Copy "$end_path"/"$backup_dir"/"$1" to "$end_path"/ on node "$node_id" ****"
      rcp $node_id":"$end_path"/"$backup_dir"/"$1 $node_id":"$end_path"/"
   fi
done

echo "******************* BACKOUT COMPLETE *******************"
