#!/usr/bin/ksh
echo "-------------------------------------------------------------------------------------------------------"
echo "Stats should only appear for one date (the latest date) - any other date and something may have failed."
echo "-------------------------------------------------------------------------------------------------------"

echo "***** START / FINISH TIME *****"
echo "Please enter the date of analysis below in the form DD/MM/YYYY"
sqlplus -s dw/dbp @analyze_finished.sql

echo "***** NUMBER OF TABLE PARTITIONS ANALYZED *****"
sqlplus -s dw/dbp @analyzed_tab_part.sql

echo "***** NUMBER OF INDEX PARTITIONS ANALYZED *****"
sqlplus -s dw/dbp @analyzed_ind_part.sql

echo "***** NUMBER OF NON-SEASONAL TABLE PARTITIONS ANALYZED *****"
sqlplus -s dw/dbp @analyzed_nons_tab_part.sql

echo "***** NUMBER OF NON-PARTITIONED TABLES ANALYZED *****"
sqlplus -s dw/dbp @analyzed_tab_non_part.sql

echo "***** SEASONS ANALYZED *****"
sqlplus -s dw/dbp @analyzed_seasons.sql

echo "------------------------------------------------------------------------------------"
echo "You can also run:"
echo "ANALYZED_PART_TIMES.SQL to get the time each partition was analyzed."
echo "ANALYZED_NON_PART_TIMES.SQL to get the time each non-partitioned table was analyzed."
echo "------------------------------------------------------------------------------------"

exit
