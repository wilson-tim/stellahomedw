--This is field_count.sql
spool field_count.lis
set newpage 0
set verify off
set heading on
set feedback off
set termout on
set pagesize 100
set linesize 220
col owner format a8 trunc heading 'Owner'
col table_name format a40 trunc heading 'Table'
col field_count format b999 heading 'Field|Count'
col today new_value xtoday noprint format a1 trunc
select to_char(sysdate,'DY: DD-MON-YYYY') today from dual;
break on owner skip 1 nodup
compute count of field on owner
ttitle left '[Page Number:' format 999999 sql.pno ']  <<'xtoday'>> -
[Filename: fields.sql]' skip 1-
'<<< This counts fields - excluding span and details_updated_date >>>' skip 2
select lower(owner) owner,lower(table_name) table_name,count(column_name) field_count from all_tab_columns
where table_name=upper('&1')
and column_name!='SPAN' and column_name!='DETAILS_UPDATED_DATE'
group by lower(owner),lower(table_name)
;

