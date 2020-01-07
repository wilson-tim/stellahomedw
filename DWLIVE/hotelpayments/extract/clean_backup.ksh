# This script delete files from /data/hotelpayments/backup which are older than 100 days 
#It is called once a week from crontab 


#################################################################################################################
#Date         Who   Description
#15/04/02     JR    Initial Version

#################################################################################################################


f_backup_path="/data/hotelpayments/backup"
 

echo "About to delete the following old backup files from $f_backup_path"
#find $f_backup_path $f_backup_path/*.*  -mtime +50 -exec   ls -ltr  {}  \;
find $f_backup_path $f_backup_path/*.*  -mtime +40 -exec  rm  -f  {}  \;

f_backup_path="/data/hotelpayments/import/logdata"
echo "About to delete the following old log files  from $f_backup_path"
#find $f_backup_path $f_backup_path/*.*  -mtime +60 -exec   ls -ltr  {}  \;
find $f_backup_path $f_backup_path/*.*  -mtime +60 -exec  rm  -f  {}  \;

f_backup_path="/data/hotelpayments/import/backup"
echo "About to delete the following old log filesi  from $f_backup_path"
#find $f_backup_path $f_backup_path/*.*  -mtime +60 -exec   ls -ltr  {}  \;
find $f_backup_path $f_backup_path/*.*  -mtime +60 -exec  rm  -f  {}  \;
echo "JOB FINISHED, exiting"





