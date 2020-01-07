LOAD DATA
INFILE '/data/hotelpayments/import/act_invextra.a'
APPEND
INTO  TABLE iacs.temp_invoice_extras
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(invoice_num, property_num,invoice_date Date(8) "RRRRMMDD", type, expense_code, 
extra_amt, extra_payment_amt, text)





