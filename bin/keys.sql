--This is keys.sql
spool keys.lis
set newpage 0
set verify off
set heading on
set feedback off
set termout on
set pagesize 100
set linesize 220
col today new_value xtoday noprint format a1 trunc
select to_char(sysdate,'DY: DD-MON-YYYY') today from dual;
col owner format a8 trunc
col table_name format a25 trunc
col constraint_name format a25 trunc
col column_name format a28 trunc
ttitle left '[Page Number:' format 999999 sql.pno ']  <<'xtoday'>> -
[Filename: Keys.sql]' skip 1-
'<<< This gives info on the key columns. If second report showing children not present - there are no children >>>' skip 2
break on owner on table_name skip 1 on constraint_name

select b.owner,b.table_name,b.constraint_name,b.column_name
from all_cons_columns b
where b.table_name=upper('&1') 
and b.constraint_name not like 'SYS%'
order by b.owner,b.table_name,b.constraint_name;

ttitle left '[Page Number: ' format 999999 sql.pno  ']     <<'xtoday'>>    -
[Filename:  keys.sql]' skip 1- 
'<<< This shows children (if any) of a table >>>' skip 2
break on parent skip 1 on owner
select uc1.table_name parent,uc2.owner owner,uc2.table_name children,uc2.constraint_name constraint_name
from all_constraints uc1,all_constraints uc2
where uc1.table_name = upper('&1')
--and uc1.constraint_type='P'
and uc1.constraint_name=uc2.r_constraint_name
--and uc2.constraint_type='R'
order by uc1.table_name,uc2.owner,uc2.table_name;
