/*  This Program will insert booking_accom_invoice from temp_booking_accom_invoice table and delete from 
temp tables */ 

-- 14/11/05 Paul Butler  Set company_code according to value of c_bai.invoice_matched_property_num
-- 27/07/07 Paul Butler  Set company_code according to value on Booking table (previous method doesn't work now that
--                       IACS H&J Travelink bookings are fed back into DW
set serveroutput on

DECLARE

Cursor c_1 IS 
        SELECt t.booking_seq_num,t.booking_accom_seq_num ,t.booking_accom_invoice_seq_num,t.invoice_matched_num,t.invoice_matched_on_date,
               t.invoice_matched_by_user,t.invoice_amt, t.payment_amt, t.reason_code, t.matched_batch_num, t.language_code, 
               t.extras_overcharge_text, t.released_from_held_ind, t.aptos_extracted_date, t.debit_note_free_text, t.debit_note_ind,
               t.invoice_matched_property_num, b.company_code
        FROM   iacs.temp_booking_accom_invoice t, booking b 
        WHERE  t.booking_seq_num = b.booking_seq_num;

ls_rec    varchar2(2000);
ls_msg   varchar2(2000);
v_company_code          booking_accom.company_code%TYPE;

BEGIN

  FOR c_bai IN c_1 LOOP

   Begin

   SELECT company_code
   INTO   v_company_code
   FROM   booking
   WHERE  booking_seq_num = c_bai.booking_seq_num;
  
   Insert into iacs.booking_accom_invoice   
     values (c_bai.booking_seq_num, c_bai.booking_accom_seq_num, c_bai.booking_accom_invoice_seq_num, c_bai.invoice_matched_num,
             c_bai.invoice_matched_on_date, c_bai.invoice_matched_by_user,c_bai.invoice_amt,c_bai.payment_amt, c_bai.reason_code,
             c_bai.matched_batch_num, c_bai.language_code, c_bai.extras_overcharge_text, c_bai.released_from_held_ind,
             c_bai.aptos_extracted_date,c_bai.debit_note_free_text, c_bai.debit_note_ind, c_bai.invoice_matched_property_num,
             c_bai.company_code ) ;
-- 27/07/07  CASE WHEN c_bai.invoice_matched_property_num > 999999999 THEN 'HAJ' ELSE 'FCHF' END ) ;
  

    EXCEPTION
      
     WHEN others then
               
       ls_rec := c_bai.booking_seq_num||','||c_bai.booking_accom_seq_num||','|| c_bai.booking_accom_invoice_seq_num
                 ||','|| c_bai.invoice_matched_num||','||c_bai.invoice_matched_on_date||','|| c_bai.invoice_matched_by_user
                 ||','||c_bai.invoice_amt||','||c_bai.payment_amt||','|| c_bai.reason_code||','||c_bai.matched_batch_num
                 ||','|| c_bai.language_code||','|| c_bai.extras_overcharge_text||','|| c_bai.released_from_held_ind
                 ||','||c_bai.aptos_extracted_date||','||c_bai.debit_note_free_text||','|| c_bai.debit_note_ind
                 ||','|| c_bai. invoice_matched_property_num ;

       ls_msg := sqlcode ||' :' || sqlerrm ;
       INSERT into iacs.loader_msgs
       VALUES (ls_msg, 'BOOKING_ACCOM_INV', ls_rec, sysdate);
 
   End ;

  END LOOP ;
  
   DELETE FROM iacs.temp_booking_accom_invoice;
   COMMIT;

EXCEPTION
    WHEN others then
    dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;
    ROLLBACK ;
    DELETE FROM iacs.temp_booking_accom_invoice;
    COMMIT;
       
END ;
/

exit
