LOAD DATA
INFILE '/data/hotelpayments/import/act_inv.a'
APPEND
INTO  TABLE iacs.temp_invoice
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(inv_seq_no, invoice_num, property_num, batch_num, invoice_date Date(8) "RRRRMMDD", 
invoice_amt, date_from Date(8) "RRRRMMDD", date_to Date(8) "RRRRMMDD", entry_user, 
entry_date Date(17) "RRRRMMDD HH24:MI:SS", amended_user, amended_date_time Date(17) "RRRRMMDD HH24:MI:SS",
 amended_process, type_of_contract, ccy_code, extras_overcharge_text, 
total_extras_amt, total_extras_payment_amt, aptos_n_code, otop_accom_code, season, debit_note_ind,
aptos_extracted_date Date(17) "RRRRMMDD HH24:MI:SS",extras_only_ind, office_code)



