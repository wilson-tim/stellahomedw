/* show exceptions from overnight processing 
where gums mapping was all acknowledged but is no longer */
set feedback off
   set linesize 200
set echo OFF
 set verify OFF
--set heading off
set pagesize 100

select t.parameter2 "Cannot Load - Missing Prop" , max(t.datetime_errors_found) "Date of error" from iacs_general_error t
where t.datetime_errors_found > sysdate -7
group by t.parameter2
/
exit;

