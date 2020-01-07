set pagesize 999
set linesize 200
col box format a8 trunc
col instance format a8 trunc
select host_name box,instance_name instance
from v$instance;
