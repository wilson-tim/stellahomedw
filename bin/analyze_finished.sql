SELECT MIN(TO_CHAR(last_analyzed,'dd/mm/yyyy hh24:mi:ss')) Started,
       MAX(TO_CHAR(last_analyzed,'dd/mm/yyyy hh24:mi:ss')) Finished
FROM dba_tab_partitions
WHERE TO_CHAR(last_analyzed,'dd/mm/yyyy') = '&Date_of_analysis'
AND table_owner = 'DATAW'
/
QUIT
