SELECT TO_CHAR(last_analyzed,'dd/mm/yyyy') Analyzed,
       COUNT(*) Table_Partitions
FROM dba_tab_partitions
WHERE table_owner = 'DATAW'
GROUP BY TO_CHAR(last_analyzed,'dd/mm/yyyy')
/
QUIT
