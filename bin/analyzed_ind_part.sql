SELECT TO_CHAR(last_analyzed,'dd/mm/yyyy') Analyzed,
       COUNT(*) Index_Partitions
FROM dba_ind_partitions
WHERE index_owner = 'DATAW'
GROUP BY TO_CHAR(last_analyzed,'dd/mm/yyyy')
/
QUIT
