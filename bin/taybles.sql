spool taybles.lis
set newpage 0
set verify off
set heading on
set feedback off
set termout on
set pagesize 100
set linesize 220
col today new_value xtoday noprint format a1 trunc
select to_char(sysdate,'DY: DD-MON-YYYY') today from dual;
col owner format a5 trunc
col tayble format a32 trunc heading 'Table'
col search_col format a32 trunc heading 'Search_col'
col nullable format a9 trunc heading 'nullable?'
break on owner skip 1 nodup
ttitle left '[Page Number:' format 999999 sql.pno ']  <<'xtoday'>> -
[Filename: taybles.sql]' skip 1-
'<<< This lists the owner and tables containing a particular fields.  >>>' skip 2
select distinct owner,lower(table_name) tayble,lower(column_name)||'  '||
decode(instr(data_type,'CHAR'),0,
decode(instr(data_type,'NUM'),0,null,data_type||'('||data_precision||','||data_scale||')'),
data_type||'('||data_length||')')
 search_col,nullable from all_tab_columns
where column_name=upper('&1')
order by owner,lower(table_name)||',';
