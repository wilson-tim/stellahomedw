/*  This Program will insert booking_accom_invoice from temp_booking_accom_invoice table and delete from 
temp tables */ 

-- 14/11/05 Paul Butler  Set company_code according to value of c_bai.invoice_matched_property_num
set serveroutput on

Declare

Cursor c_1 IS 
        SELECt booking_seq_num,booking_accom_seq_num ,booking_accom_invoice_seq_num,invoice_matched_num,invoice_matched_on_date,
               invoice_matched_by_user,invoice_amt,payment_amt, reason_code, matched_batch_num, language_code, 
               extras_overcharge_text, released_from_held_ind, aptos_extracted_date, debit_note_free_text, debit_note_ind,
               invoice_matched_property_num
        FROM iacs.temp_booking_accom_invoice ;

ls_rec    varchar2(2000);
ls_msg   varchar2(2000);

BEGIN

  FOR c_bai IN c_1 LOOP

   Begin
  
   Insert into iacs.booking_accom_invoice   
     values (c_bai.booking_seq_num, c_bai.booking_accom_seq_num, c_bai.booking_accom_invoice_seq_num, c_bai.invoice_matched_num,
             c_bai.invoice_matched_on_date, c_bai.invoice_matched_by_user,c_bai.invoice_amt,c_bai.payment_amt, c_bai.reason_code,
             c_bai.matched_batch_num, c_bai.language_code, c_bai.extras_overcharge_text, c_bai.released_from_held_ind,
             c_bai.aptos_extracted_date,c_bai.debit_note_free_text, c_bai.debit_note_ind, c_bai.invoice_matched_property_num,
             CASE WHEN c_bai.invoice_matched_property_num > 999999999 THEN 'HAJ' ELSE 'FCHF' END ) ;
  

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
