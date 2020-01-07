 -- V1.19 Jyoti :  For H & J bookings  update those  accrual's where currency is corrected from ??? to USD
 -- to exclude_payment_ind =Y so those bookings with currency ??? will not appear in the iacs

 Declare
          Cursor reset_hjbookings Is
          Select ba.booking_seq_num, ba.booking_accom_seq_num
          From iacs.booking_accom ba, iacs.booking b
          Where b.booking_seq_num = ba.booking_seq_num and
                b.booking_source = 'H' and
                ba.accrual_ccy_code = '???' and
 --               ba.exclude_payment_ind <> 'Y'and 
                exists (Select null
                        From iacs.booking_accom boa
                        Where boa.booking_seq_num = ba.booking_seq_num and
                              boa.otop_accom_code = ba.otop_accom_code and
                              boa.accom_start_date = ba.accom_start_date );
v_count NUMBER :=0;
Begin
  For cloop  In reset_hjbookings Loop
  
          UPDATE iacs.booking_accom ba
          SET os_amt = 0,
              accrual_amt = 0,
              accrual_revised_by_amt = (-1 * accrual_amt),
              amended_process = 'HJ PROP CHANGE',
              amended_date_time = sysdate,
              amended_user_id = user,
              extracted_Date = null,
              exclude_payment_ind = 'Y'
          WHERE booking_seq_num = cloop.booking_seq_num
              and   booking_accom_seq_num = cloop.booking_accom_seq_num;
  
v_count := v_count +1;
End Loop;
dbms_output.put_line('total hj bookings updates :'||v_count);


end ;
/
 commit;


EXIT;


