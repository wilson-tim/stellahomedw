--This is fields.sql
spool fields.lis
set newpage 0
set verify off
set heading on
set feedback off
set termout on
set pagesize 100
set linesize 220
col owner format a8 trunc heading 'Owner'
col today new_value xtoday noprint format a1 trunc
select to_char(sysdate,'DY: DD-MON-YYYY') today from dual;
col field format a40 trunc heading 'Field'
break on owner skip 1 nodup
compute count of field on owner
ttitle left '[Page Number:' format 999999 sql.pno ']  <<'xtoday'>> -
[Filename: fields.sql]' skip 1-
'<<< This lists the owner and fields of a table >>>' skip 2
select distinct lower(owner) owner,lower(column_name)||',' field from all_tab_columns
where table_name=upper('&1')
order by lower(owner),lower(column_name)||',';

