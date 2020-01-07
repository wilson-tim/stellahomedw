
set numwidth 30
set feedback off
set lines 2000


prompt Enter Extracted Date along with time 
Prompt (enter in format dd-mon-yyyy hh24:mi:ss)

accept extracted_date char  prompt 'Aptos Extracted Date: >'

spool dw_actrecon_2.lst 
    

Select office_code||chr(9)||inv_seq_no||chr(9)||invoice_num||chr(9)||property_num||chr(9)||invoice_amt
from invoice
where aptos_extracted_date = to_date('&extracted_date','DD-MON-YYYY hh24:mi:ss') 
;

spool off
 
