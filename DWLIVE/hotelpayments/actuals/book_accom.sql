/*  This Program will update booking_accom from temp_booking table and delete from 
temp tables */ 

set serveroutput on size 1000000

Declare

Cursor c_1 IS 
        SELECt booking_seq_num,booking_accom_seq_num ,os_amt, 
               multi_invoice_ind, held_code,accrual_ccy_code, property_num
        FROM iacs.temp_booking_accom ;

ls_rec   varchar2(2000);
ls_msg   varchar2(2000);
BEGIN

  FOR c_ba IN c_1 LOOP

Begin
  begin
   Update iacs.booking_accom
    Set os_amt = c_ba.os_amt ,
        multi_invoice_ind = c_ba.multi_invoice_ind ,
        held_code = c_ba.held_code ,
        accrual_ccy_code = c_ba.accrual_ccy_code
    Where booking_seq_num = c_ba.booking_seq_num AND
          booking_accom_seq_num = c_ba.booking_accom_seq_num ;
  EXCEPTION
    WHEN dup_val_on_index THEN
      -- duplicate because accrual was a dummy accrual with currency of ??? and property_Num of 4932 but has now changed
      -- to a proper property_num/ccy with a different booking_Accom_seq_num -- update this proper one instead
      dbms_output.put_line('dupval');
      Update iacs.booking_accom
         Set os_amt = c_ba.os_amt ,
         multi_invoice_ind = c_ba.multi_invoice_ind ,
         held_code = c_ba.held_code 
         Where booking_seq_num = c_ba.booking_seq_num AND
          property_num = c_ba.property_num AND
          accrual_ccy_code = c_ba.accrual_ccy_code;
  END;



/*  exception will not fire if there is no booking_accom record */
if SQL%ROWCOUNT = 0 then 

     dbms_output.put_line('0 rows updated, '||sqlcode || ' : ' || sqlerrm) ;
     dbms_output.put_line('going to update ??? row') ;

      Update iacs.booking_accom
         Set os_amt = c_ba.os_amt ,
         multi_invoice_ind = c_ba.multi_invoice_ind ,
        accrual_ccy_code = c_ba.accrual_ccy_code,
         held_code = c_ba.held_code 
         Where booking_seq_num = c_ba.booking_seq_num AND
          property_num = c_ba.property_num AND
          accrual_ccy_code = '???';
     
     if SQL%ROWCOUNT = 0 then 

       dbms_output.put_line('0 ???  rows updated, '||sqlcode || ' : ' || sqlerrm) ;
       dbms_output.put_line('going to update ??? row') ;
       ls_rec := c_ba.booking_seq_num || ',' || c_ba.booking_accom_seq_num ||','||c_ba.property_num|| ',' || c_ba.os_amt
                  || ',' || c_ba.multi_invoice_ind || ',' || c_ba.held_code|| ','||c_ba.accrual_ccy_code ; 
       dbms_output.put_line(ls_rec);
       ls_msg := 'Booking accom record ??? not found' ;
       Insert into iacs.loader_msgs
       values (ls_msg, 'BOOKING_ACCOM', ls_rec, sysdate);
     end if;
end if;

EXCEPTION
    WHEN others then
      
    -- dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;
      ls_rec := c_ba.booking_seq_num || ',' || c_ba.booking_accom_seq_num || ','||c_ba.property_num||',' || c_ba.os_amt
                || ',' || c_ba.multi_invoice_ind || ',' || c_ba.held_code||','||c_ba.accrual_ccy_code ; 
       
      ls_msg := sqlcode ||' :' || sqlerrm ;
      Insert into iacs.loader_msgs
      values (ls_msg, 'BOOKING_ACCOM', ls_rec, sysdate);

End ;
   End Loop ;
  
   DELETE FROM iacs.temp_booking_accom;
   COMMIT ;

EXCEPTION
    WHEN others then
         dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;
         ROLLBACK;
         DELETE FROM iacs.temp_booking_accom;
         COMMIT ;
            


END ;
/

exit
