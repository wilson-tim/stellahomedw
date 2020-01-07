#!/usr/bin/ksh
#
# retail_move_out_data.ksh                 
#Prior to archiving. Moves retail  stuff into the retail_archive directory  
#immediately after retail integration                    
#where it remains for two days until stored and zipped by retail_store_and_zip.ksh
# Don't use mv
cp  /data/retail/fx/*.lis   /data/retail_archive
rm  /data/retail/fx/*.lis 
#

