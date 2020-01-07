SELECT table_name,partition_name,
       TO_CHAR(last_analyzed,'dd/mm/yyyy hh24:mi:ss') Last_Analyzed
FROM dba_tab_partitions
WHERE TO_CHAR(last_analyzed,'dd/mm/yyyy') = '&Date_of_analysis'
AND table_owner = 'DATAW'
ORDER BY last_analyzed
/
QUIT
