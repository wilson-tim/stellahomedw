

set serveroutput on size 1000000

set doc off verify off

/*
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
* Name: fch_merge_rejects.sql                                                                      *
*                                                                                                  *
* Purpose                                                                                          *
* -------                                                                                          *
* Merges rejected records back into a load table and clears the reject table.                      *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*  History                                                                                         *
*  -------                                                                                         *
*                                                                                                  *
* Date      By         Description                                                                 *
* --------  ---------- --------------------------------------------------------------------------- *
* 10/12/02  A.James    Initial version.                                                            *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
* Input Parameters                                                                                 *
* ----------------                                                                                 *
*                                                                                                  *
* &1   Target table name.                                                                          *
* &2   Source table name containing the reject records.                                            *
* &3   Debug mode.                                                                                 *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
* To Do                                                                                            *
* -----                                                                                            *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*/

-- Exit with an exit code of 1 if an operating system error and exit with the sql error code for an
-- SQL error or PL/SQL error.
whenever oserror exit 1
whenever sqlerror exit sql.sqlcode

set doc on

/*
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
*                                    Body of SQL script follows.                                   *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*/

define target_table_name=&1
define source_table_name=&2
define debug_mode=&3

sho user

-- Set debug mode
exec p_common.set_debug_mode('&debug_mode') 

-- Merge the reject records.
DECLARE
  v_insert_count       INTEGER;
BEGIN
  p_common.do_insert('&target_table_name','&source_table_name',p_out_insert_count => v_insert_count); 
  dbms_output.put_line(v_insert_count||' records inserted into '||'&target_table_name');
END;
/

-- Clear the reject table.
truncate table &source_table_name;

/*
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
*                                          End of SQL script.                                      *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*/

-- Exit with a successful code of 0.
exit 0
