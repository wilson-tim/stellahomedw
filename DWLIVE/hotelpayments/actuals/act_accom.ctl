LOAD DATA
INFILE '/data/hotelpayments/import/act_accom.a'
APPEND
INTO  TABLE iacs.temp_booking_accom
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(booking_seq_num, booking_accom_seq_num, property_num, accrual_amt, accom_start_date Date(8) "RRRRMMDD", 
 amended_date_time Date(17) "RRRRMMDD HH24:MI:SS", amended_user_id, amended_process, accrual_ccy_code,
OS_AMT, multi_invoice_ind, otop_accom_code, held_code, accrual_revised_by_amt )



