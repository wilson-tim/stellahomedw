/*  This Program will insert booking_accom_extras from temp_booking_accom_extras table and delete from 
temp tables */ 

set serveroutput on
Declare

CURSOR c_1 IS 
        SELECT booking_seq_num,booking_accom_seq_num ,type, expense_code, extra_amt, booking_accom_invoice_seq_num,
               extra_payment_amt, text
        FROM iacs.temp_booking_accom_extras ;

ls_rec     varchar2(2000);
ls_msg     varchar2(2000);

BEGIN

  FOR c_baext IN c_1 LOOP

  BEGIN
     Insert into iacs.booking_accom_extras
     values (c_baext.booking_seq_num, c_baext.booking_accom_seq_num, c_baext.type, c_baext.expense_code,
             c_baext.extra_amt, c_baext.booking_accom_invoice_seq_num, c_baext.extra_payment_amt, c_baext.text ) ;

    EXCEPTION

      WHEN others then
        ls_rec := c_baext.booking_seq_num||','||c_baext.booking_accom_seq_num||','||c_baext.type
                  ||','||c_baext.expense_code||','||c_baext.extra_amt||','||c_baext.booking_accom_invoice_seq_num
                  ||','||c_baext.extra_payment_amt||','||c_baext.text  ;
       
       ls_msg := sqlcode || ' : ' || sqlerrm ;
       INSERT into iacs.loader_msgs
       VALUES (ls_msg, 'BOOKING_ACCOM_EXTRAS', ls_rec, sysdate);


 END  ;
  END LOOP ;
  
   DELETE FROM iacs.temp_booking_accom_extras;
   COMMIT; 

EXCEPTION
 WHEN others then
     dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;
     ROLLBACK ;
     DELETE FROM iacs.temp_booking_accom_extras;
     COMMIT;
     dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;

END ;
/

exit
