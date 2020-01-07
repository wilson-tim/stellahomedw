SELECT TO_CHAR(last_analyzed,'dd/mm/yyyy') Analyzed,
       COUNT(*) Table_Partitions
FROM dba_tab_partitions
WHERE table_owner = 'DATAW'
AND LENGTH(partition_name) < 14
GROUP BY TO_CHAR(last_analyzed,'dd/mm/yyyy')
/
QUIT
