--This is fields.sql
spool fields.lis
set newpage 0
set verify off
set heading on
set feedback off
set termout on
set pagesize 100
set linesize 220
col field format a40 trunc heading 'Field'
select distinct lower(column_name)||',' field from all_tab_columns
where table_name=upper('&1')
order by lower(column_name)||',';

