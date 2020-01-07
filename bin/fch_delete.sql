

set serveroutput on size 1000000

set doc off

/*
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
* Name: fch_delete.sql                                                                             *
*                                                                                                  *
* Purpose                                                                                          *
* -------                                                                                          *
* Clears out a specified table using delete.                                                       *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*  History                                                                                         *
*  -------                                                                                         *
*                                                                                                  *
* Date      By         Description                                                                 *
* --------  ---------- --------------------------------------------------------------------------- *
* 14/04/03  A.James    Initial version.                                                            *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
* Input Parameters                                                                                 *
* ----------------                                                                                 *
*                                                                                                  *
* &1   Name of table to be deleted.                                                                *
* &2   Debug mode.                                                                                 *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
* Notes                                                                                            *
* -----                                                                                            *
* 1. Used instead of truncate as truncate doesn't work for tables with enabled foreign keys.       *
* 2. Be careful number of rows in the table isn't too large as delete could take a long time or    *
*    fail with rollback segments too small.                                                        *
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

define clear_table=&1
define debug_mode=&2

-- Set debug mode
exec p_common.set_debug_mode('&debug_mode') 

delete from &clear_table;
commit;

/*
* ------------------------------------------------------------------------------------------------ *
*                                                                                                  *
*                                          End of SQL script.                                      *
*                                                                                                  *
* ------------------------------------------------------------------------------------------------ *
*/

-- Exit with a successful code of 0.
exit 0
