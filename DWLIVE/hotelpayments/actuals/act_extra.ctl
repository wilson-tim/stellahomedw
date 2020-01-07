LOAD DATA
INFILE '/data/hotelpayments/import/act_extra.a'
APPEND
INTO  TABLE iacs.temp_booking_accom_extras
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(booking_seq_num, booking_accom_seq_num,type, expense_code, extra_amt, booking_accom_invoice_seq_num, 
extra_payment_amt, text)





