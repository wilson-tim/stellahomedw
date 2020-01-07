/*  This Program will insert invoice_extras from temp_invoice_extras table and delete from 
temp tables */ 
-- 14/11/05 Paul Butler  Set company_code according to value of property_num
-- 27/07/07 Paul Butler  Set company_code according to value on Invoice table (previous method no longer works as we now have
--                       IACS H&J invoices fed back into DW

set serveroutput on

Declare

v_company_code   invoice.company_code%TYPE;

Cursor c_1 IS 
        SELECT invoice_num, property_num, invoice_date, type, expense_code, extra_amt, extra_payment_amt, text
        FROM iacs.temp_invoice_extras ;

ls_rec   varchar2(2000);
ls_msg   varchar2(2000);

BEGIN

  FOR c_ext IN c_1 LOOP
  
  BEGIN
       -- 27/07/07 PGB Get company_code from Invoice table
       SELECT company_code 
       INTO   v_company_code
       FROM   invoice
       WHERE  invoice_num = c_ext.invoice_num
       AND    property_num = c_ext.property_num
       AND    invoice_date = c_ext.invoice_date;
       
       EXCEPTION
         WHEN OTHERS THEN
           v_company_code := 'FCHF';
  END ;
  
 Begin 
     Insert into iacs.invoice_extras
     values (c_ext.invoice_num, c_ext.property_num, 
--           CASE WHEN c_ext.property_num > 999999999 THEN 'HAJ' ELSE 'FCHF' END,
             v_company_code, 
             c_ext.invoice_date, c_ext.type, c_ext.expense_code,c_ext.extra_amt,
             c_ext.extra_payment_amt, c_ext.text );

    EXCEPTION
      WHEN others then
       ls_rec := c_ext.invoice_num || ',' || c_ext.property_num || ',' || c_ext.invoice_date || ',' || c_ext.type 
                 || ',' || c_ext.expense_code || ',' || c_ext.extra_amt || ',' || c_ext.extra_payment_amt
                 || ',' || c_ext.text ;

       ls_msg := sqlcode ||' :' || sqlerrm ;
       Insert into iacs.loader_msgs
       Values (ls_msg, 'INVOICE_EXTRAS', ls_rec, sysdate);

 End ;
  END LOOP ;
  
   DELETE FROM iacs.temp_invoice_extras ;
   COMMIT;

EXCEPTION
WHEN others then
    dbms_output.put_line(sqlcode || ' : ' || sqlerrm) ;
     ROLLBACK ;
     DELETE FROM iacs.temp_invoice_extras ;
     COMMIT;


END ;
/

exit
