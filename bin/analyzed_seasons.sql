SELECT DISTINCT TO_CHAR(last_analyzed,'dd/mm/yyyy') Analyzed,
       SUBSTR(partition_name,-5,3) Season
FROM dba_tab_partitions
WHERE table_owner = 'DATAW'
/
QUIT
