LOAD DATA
INFILE '/data/hotelpayments/import/act_accom_inv.a'
APPEND
INTO  TABLE iacs.temp_booking_accom_invoice
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(booking_seq_num, booking_accom_seq_num,booking_accom_invoice_seq_num, invoice_matched_num, 
invoice_matched_on_date Date(17) "RRRRMMDD HH24:MI:SS", invoice_matched_by_user, invoice_amt, 
payment_amt, reason_code, matched_batch_num, language_code, extras_overcharge_text, 
released_from_held_ind, aptos_extracted_date Date(17) "RRRRMMDD HH24:MI:SS", debit_note_free_text,
debit_note_ind,invoice_matched_property_num)




