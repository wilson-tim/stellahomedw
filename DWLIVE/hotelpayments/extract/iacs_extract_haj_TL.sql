/*   This program will call package procedures */ 
/* to extract iacs data from iacs tables into files to be interfaced to iacs Hayes and Jarvis database */


SET SERVEROUTPUT ON size 1000000

BEGIN

/*  Pass : 'R' for Reference data only
           'B' for Bookings only
           'A' extract All
*/

    pkg_create_ref_book_file_haj.sp_create_file('A');
     


END ;

/
exit
