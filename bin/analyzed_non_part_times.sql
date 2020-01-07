SELECT table_name,
       TO_CHAR(last_analyzed,'dd/mm/yyyy hh24:mi:ss') Last_Analyzed
FROM dba_tables
WHERE TO_CHAR(last_analyzed,'dd/mm/yyyy') = '&Date_of_analysis'
AND owner = 'DATAW'
AND partitioned = 'NO'
ORDER BY last_analyzed
/
QUIT

