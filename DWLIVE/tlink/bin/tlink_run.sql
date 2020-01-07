-- ***************************************************************************
--
-- $Header: tlink_run.sql
-- $Name:  $
--
-- $RCSfile: tlink_run.sql,v $
--
-- $Log: tlink_run.sql,v $
-- Version 1.0  09/11/2005 S.R.Williams
--
--
-- ***************************************************************************
-- Script to call the warehouse loading scheduler in the TLINKW schema and
-- process the Travelink data from the staging area into the warehouse tables.
-- ***************************************************************************

set feedback off
set verify off
set feedback off
set verify off
set heading off
set echo off
set pagesize 0

variable vExitCode number
whenever sqlerror exit sql.sqlcode

define wait_for_job_name=&1
define wait_seconds=&2
define application_key=&3
define sql_debug_mode=&4

-- Set debug mode
exec p_common.set_debug_mode('&sql_debug_mode') 
  

begin

 --   :vExitCode := pkg_tl_w_run.do_run_wait( '&wait_for_job_name', &wait_seconds, '&application_key' );

:vExitCode := tlink_update_load_all(sysdate); 

end;
/
exit :vExitCode

