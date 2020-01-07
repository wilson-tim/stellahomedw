

set serveroutput on size 1000000

set doc off

/*
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
* Name: fch_trunc.sql                                                                              *
*                                                                                                  *
* Purpose                                                                                          *
* -------                                                                                          *
* Truncates a specified table.                                                                     *
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
* &1   Name of table to be truncated.                                                              *
* &2   Debug mode.                                                                                 *
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

define trunc_table_name=&1
define debug_mode=&2

-- Set debug mode
exec p_common.set_debug_mode('&debug_mode') 

truncate table &trunc_table_name;

/*
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
*                                          End of SQL script.                                      *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*/

-- Exit with a successful code of 0.
exit 0
