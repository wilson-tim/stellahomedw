/*  This Program will insert invoice from temp_invoice table and delete from 
temp tables */ 

-- 14/11/05 Paul Butler  Set company code according to property_num

set serveroutput on
Declare

CURSOR  c_1 IS 
        SELECT inv_seq_no, invoice_num, property_num, batch_num, invoice_date, invoice_amt, date_from, date_to, entry_user,
               entry_date, amended_user, amended_date_time, amended_process, type_of_contract, ccy_code, extras_overcharge_text,
               total_extras_amt, total_extras_payment_amt, aptos_n_code, otop_accom_code, season, debit_note_ind,
               aptos_extracted_date,  extras_only_ind,office_code
        FROM iacs.temp_invoice ;

ls_rec    varchar2(2000);
ls_msg    varchar2(2000);

BEGIN
  FOR c_inv IN c_1 LOOP
 BEGIN 
     INSERT into iacs.invoice
     VALUES (c_inv.inv_seq_no, c_inv.invoice_num, c_inv.property_num, CASE WHEN c_inv.property_num > 999999999 THEN 'HAJ' ELSE 'FCHF' END,
             c_inv.batch_num, c_inv.invoice_date, c_inv.invoice_amt,
             c_inv.date_from,c_inv.date_to, c_inv.entry_user, c_inv.entry_date, c_inv.amended_user, c_inv.amended_date_time,
             c_inv.amended_process, c_inv.type_of_contract, c_inv.ccy_code, c_inv.extras_overcharge_text,
             c_inv.total_extras_amt, c_inv.total_extras_payment_amt, c_inv.aptos_n_code, c_inv.otop_accom_code, c_inv.season,
             c_inv.debit_note_ind, c_inv.aptos_extracted_date,  c_inv.extras_only_ind,  c_inv.office_code  );

    EXCEPTION
     WHEN others then
  
--dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;  
       
       ls_rec := c_inv.inv_seq_no||','||c_inv.invoice_num||','||c_inv.property_num||','||c_inv.batch_num
                 ||','||c_inv.invoice_date||','||c_inv.invoice_amt||','||c_inv.date_from||','||c_inv.date_to
                 ||','||c_inv.entry_user||','||c_inv.entry_date||','||c_inv.amended_user
                 ||','||c_inv.amended_date_time||','||c_inv.amended_process||','||c_inv.type_of_contract
                 ||','||c_inv.ccy_code||','||c_inv.extras_overcharge_text||','||c_inv.total_extras_amt
                 ||','||c_inv.total_extras_payment_amt||','||c_inv.aptos_n_code||','||c_inv.otop_accom_code
                 ||','||c_inv.season||','||c_inv.debit_note_ind||','||c_inv.aptos_extracted_date||','||c_inv.extras_only_ind
                 ||','||c_inv.office_code ;
     
       ls_msg := sqlcode ||' :' || sqlerrm ;
       INSERT into iacs.loader_msgs
       VALUES (ls_msg, 'INVOICE', ls_rec, sysdate);

 End ;
  END LOOP ;
  
   DELETE FROM iacs.temp_invoice ;
   COMMIT;

EXCEPTION
    WHEN others then
     dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;  
     ROLLBACK ;
     DELETE FROM iacs.temp_invoice ;
     COMMIT;  


END ;
/

exit
