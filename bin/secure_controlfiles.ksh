# LA Nov 2002 New script to secure main files used in integration
#
#check for existence of files
#change properties to read-only
# reads list of files in /home/dw/bin/controlfiles.lst

home="/home/dw/bin"
FILELIST=$home/controlfiles.lst
date
echo $FILELIST
for ctrlfile in `cat $FILELIST`
do
 # -s tests that size > 0 bytes
     if [ -s $ctrlfile ]
      then
        echo "file found:" $ctrlfile
        chmod -w $ctrlfile 
     else
        msg=" URGENT URGENT URGENT Control file missing:  `hostname` $ctrlfile"
        echo $msg
        mailx -s "$msg" leigh.ashton@firstchoice.co.uk  < $FILELIST 
        mailx -s "$msg" angela.ward@firstchoice.co.uk  < $FILELIST 
     fi

done
echo "finished"
date

