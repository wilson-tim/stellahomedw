set feedback off
     set linesize 200
     set echo OFF
     set verify OFF
 
select substr(m.error_msg,16,50), substr(m.table_nm,1,20), substr(m.error_record,1,30), to_date(m.loaded_datetime,'dd-mon-yyyy hh24:mi') 
from iacs.loader_msgs  m 
where  loaded_datetime > sysdate-1;
 
    exit
