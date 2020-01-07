/*   This program will call package procedures */ 
/* to extract iacs data from iacs tables into files to be interfaced to iacs databases around the world */


SET SERVEROUTPUT ON size 1000000

BEGIN

/*  Pass : 'R' for Reference data only
           'B' for Bookings only
           'A' extract All
*/

    pkg_create_ref_book_file.sp_create_file('A');
     


END ;

/
exit
