LOAD DATA
INFILE 'act_book.a'
BADFILE 'act_book.bad'
DISCARDFILE 'act_book.dsc'
APPEND
INTO  TABLE iacs.temp_booking
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(booking_seq_num, booking_ref, 
arrival_date Date(8) "RRRRMMDD", departure_date Date(8) "RRRRMMDD", lead_passenger_name, no_of_adults, no_of_children,
no_of_infants,duration, cancelled_flag, amended_date_time Date(17) "RRRRMMDD HH24:MI:SS", amended_user_id, amended_process,
season, twin_centre_ind,extracted_date Date(17) "RRRRMMDD HH24:MI:SS" )

