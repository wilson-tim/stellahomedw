-- check for lastest poll times for each operator in late prices table
set feedback off 
set pagesize 0  
set linesize 150 
set head off   
spool &1

select 'PK_INTEGRATION is invalid'
from all_objects
where
object_type in ('PACKAGE','PROCEDURE','PACKAGE BODY','FUNCTION')
and status='INVALID'
and owner='DW'
AND object_name = 'PK_INTEGRATION'
order by object_type, object_name
/

exit;

