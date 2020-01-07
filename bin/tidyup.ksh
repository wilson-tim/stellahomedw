#!/usr/bin/ksh
. /home/dw/bin/set_oracle_variables.ksh
#_/\_/\_/\_________Rob_S________/\___
#This is tidyup.ksh (for now living in bin) to replace the delimiter in the 
#sift files with a pipe. And for removing the top (header) row.
#
# NB NB NB For this to work - (when ftpd to UNIX after editing in WORD 
#for example) we MUST immediately replace ^H below with ctrl-v ctrl-h using vi. 
#This will reproduce a ^H which works - and does the substition correctly.
#_/\_/\_/\_________Rob_S________/\___
for file in  /data/retail/fx/*.lis
do
sed "s//|/g"  $file>$file.temp1
sed  '1d' $file.temp1>$file.temp2
mv $file.temp2 $file
rm $file.temp1
done
#_/\_/\_/\_________Rob_S________/\___
