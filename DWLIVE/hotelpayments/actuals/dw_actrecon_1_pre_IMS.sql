
set numwidth 30
set feedback off
set lines 2000
set echo OFF
set verify OFF

prompt Enter Date range for reconciliation 
prompt (enter in format dd-mon-yyyy)
prompt 
accept from_date char  prompt 'From Date: >'
accept to_date char prompt 'To Date: >'

prompt Enter office code 
accept office_cd  prompt 'Office code: >'

compute SUM label 'Grand Total :' of Invoice_amt ON report
compute SUM of Bai_Invoice_amt ON report
compute SUM of Bai_payment_amt ON report
BREAK ON report

spool dw_actrecon_1.lst 

COLUMN DUMMY HEADING ''
Select '              ' dummy,i.office_code office,to_char(i.aptos_extracted_date,'DD-MON-YYYY HH24:MI:SS'),
       sum(i.invoice_amt) Invoice_amt, sum(bai.invoice_amt) Bai_Invoice_amt, sum(bai.payment_amt) Bai_Payment_Amt
from invoice i , booking_accom_invoice bai
where trunc(i.aptos_extracted_date)  between to_date('&from_date','DD-MON-YYYY') and  to_date('&to_date','DD-MON-YYYY')  and
      i.invoice_num = bai.invoice_matched_num(+) and
      i.property_num = bai.invoice_matched_property_num(+)  and
   i.batch_num = bai.matched_batch_num(+) and
      i.office_code like '&office_cd' 
group by i.office_code,i.aptos_extracted_date ;


spool off
 
