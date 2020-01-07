#This is /home/dw/DWLIVE/load/retail/get_rates.ksh 
#for ftp and processing of the rates file for retail. 
#
#!/user/bin/ksh
cd /data/retail/fx
ftp -n -v -i <<\rob_s
open  10.20.1.62
user misftp misftp
mget fcrates*.csv
quit
rob_s

#below creates variable today -  in format like 20020712
today=`date +%Y%0m%d`

#In the case of the rates file (independantly received) the delimiter is a comma. 
#Change to a pipe. And we may as well rename in line with SIFT files at the same time.
#This enables subsequent processing to be grouped with the SIFT files.
sed "s/,/|/g" fcrates*.csv >"rates_"$today".lis"
rm fcrates*.csv
