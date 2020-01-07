sqlplus -s -LOGON ${USER}/${PASSWD} << !
set heading off
set termout off
set feedback off
set lines 120
set echo off
set verify off
  
spool ${LOGS}/tlink${RUNDATE}.inf
select t.event_summary,
       t.event_type,
       t.event_level,
       to_char(t.event_date,'dd-Mon-yy hh24:mi:ss'),
       t.event_period,
       t.event_detail
from jutil.application_log t
where t.application_key like 'TLINK%'
and t.event_date >= trunc(sysdate)
order by t.event_date asc, t.log_sequence asc;
exit
!

cat ${LOGS}/tlink${RUNDATE}.inf >> ${LOGS}/tlink${RUNDATE}.log

