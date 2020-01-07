SELECT TO_CHAR(last_analyzed,'dd/mm/yyyy') Analyzed,
       COUNT(*) Tables
FROM dba_tables
WHERE partitioned = 'NO'
AND owner = 'DATAW'
GROUP BY TO_CHAR(last_analyzed,'dd/mm/yyyy')
/
QUIT
