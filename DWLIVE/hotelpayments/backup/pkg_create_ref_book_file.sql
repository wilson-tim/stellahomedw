/*
PACKAGE NAME     : pkg_create_ref_book_file 

Revision History :

Description      :This Package will create a file ( Reference or Booking ) , 
                  extract data from dw tables,
                  and write into the file as tab seperated 

Date             created By           Comment
01/10/99         Jyoti Renganathan    Initial Version

*/

SET SERVEROUTPUT ON


CREATE OR REPLACE PACKAGE pkg_create_ref_book_file  IS
  
  v_statement_no          number ;

  PROCEDURE   sp_create_file ;
  PROCEDURE   sp_write_aptos_code_rec ;
  PROCEDURE   sp_write_currency_rec ;
  PROCEDURE   sp_write_currency_rate_rec ;
  PROCEDURE   sp_write_expense_rec ;
  PROCEDURE   sp_write_languages_rec ;
  PROCEDURE   sp_write_reason_rec ;
  PROCEDURE   sp_write_location_rec ;
  PROCEDURE   sp_write_group_rec ;
  PROCEDURE   sp_write_property_rec ;
  PROCEDURE   sp_write_otop_property_rec ;
  PROCEDURE   sp_write_booking_rec(p_office_code char) ;

END  pkg_create_ref_book_file ;
 
/

CREATE OR REPLACE PACKAGE BODY pkg_create_ref_book_file  IS
 
pi_ref_file_handle          utl_file.file_type;
pi_boo_file_handle          utl_file.file_type;
pc_season  char(3);  

CURSOR c_season IS
        SELECT Lower(season_type) || substr(season_year,3,4) 
        FROM season
        WHERE sysdate between season_start_date and season_end_date ;

CURSOR c_offices IS
        SELECT office_code 
        FROM  office
        WHERE status = 'E';
  

PROCEDURE sp_create_file IS

lc_season                       char(3);
lv_ref_filename                 varchar2(20);
lv_boo_filename                 varchar2(20);

Begin

  v_statement_no := 41;
 -- Fetch current season 
OPEN c_season ;
FETCH c_season INTO lc_season ;
CLOSE c_season ;

-- construct the  file name  : 'r' for reference and 'b' for booking 
     lv_ref_filename := to_char(sysdate,'yyyymmdd') || '_r.' || lc_season ;

dbms_output.put_line(lv_ref_filename) ;
  v_statement_no := 57 ;
 pi_ref_file_handle := utl_file.fopen('/data/hotelpayments/export',lv_ref_filename,'w') ;
  v_statement_no := 59 ;

     sp_write_aptos_code_rec ;
     sp_write_currency_rec ;
     sp_write_currency_rate_rec ;
     sp_write_expense_rec ;
     sp_write_languages_rec ;
     sp_write_reason_rec ;
     sp_write_location_rec ;
     sp_write_group_rec ;
     sp_write_property_rec ;
     sp_write_otop_property_rec ;

     utl_file.put_line(pi_ref_file_handle,'[EOF]');
     utl_file.fclose(pi_ref_file_handle) ;
-----------------------------------------------------------------------------------------------

-- Create booking file for each offices eg. cra_19991106_b.s99 , bri_19991106_b.s99
        FOR c_offices_rec IN c_offices LOOP
            lv_boo_filename := c_offices_rec.office_code || '_' || to_char(sysdate,'yyyymmdd') || '_b.' || lc_season ;

 pi_boo_file_handle := utl_file.fopen('/data/hotelpayments/export',lv_boo_filename,'w') ;
dbms_output.put_line(lv_boo_filename) ;

v_statement_no := 62 ;

  -- Call Booking procedure here  .... 
     sp_write_booking_rec(c_offices_rec.office_code) ;

        utl_file.put_line(pi_boo_file_handle,'[EOF]');
        utl_file.fclose(pi_boo_file_handle) ;

        END LOOP;
EXCEPTION 
        WHEN utl_file.invalid_path THEN
             dbms_output.put_line ('  Error at statement no.  = ' ||   v_statement_no);
             dbms_output.put_line('Error - Invalid Path ' );    
        WHEN utl_file.invalid_mode THEN
             dbms_output.put_line ('  Error at statement no.  = ' ||   v_statement_no);
             dbms_output.put_line('Error - Invalid Mode ' );    
        WHEN utl_file.invalid_operation THEN
             dbms_output.put_line ('  Error at statement no.  = ' ||   v_statement_no);
             dbms_output.put_line('Error - Invalid Operation ' );
        WHEN no_data_found then
             utl_file.fclose(pi_ref_file_handle);
             utl_file.fclose(pi_boo_file_handle);
             dbms_output.put_line ('  Error at statement no.  = ' ||   v_statement_no);
             dbms_output.put_line(sqlcode || ' :' || sqlerrm);  
        WHEN others THEN
             dbms_output.put_line ('  Error at statement no.  = ' ||   v_statement_no);
             dbms_output.put_line(sqlcode || ' :' || sqlerrm);   

END sp_create_file ;
------------------------------------------------------------------------------------------------
PROCEDURE sp_write_aptos_code_rec IS
    
        CURSOR c_aptos IS
                SELECT aptos_n_code 
                FROM aptos_code ;

        ls_data    varchar2(50);
        first_time boolean  := TRUE ;
BEGIN
        v_statement_no := 122 ;
        FOR aptos_rec in c_aptos  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[APT]');
               first_time   := FALSE ;
           END IF ;        
            -- create tab seperated string
           ls_data := aptos_rec.aptos_n_code ;
           v_statement_no := 126 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_aptos_code_rec ;
------------------------------------------------------------------------------------------------

PROCEDURE sp_write_currency_rec IS
        
        CURSOR c_cur IS
                SELECT currency_code,currency_desc   
                FROM currency ;

        ls_data    varchar2(100);
        first_time boolean := TRUE;
BEGIN
        v_statement_no := 158 ;
        FOR cur_rec in c_cur  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[CUR]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data := cur_rec.currency_code || chr(9) || cur_rec.currency_desc ;
           v_statement_no := 163 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_currency_rec ;

------------------------------------------------------------------------------------------------

PROCEDURE sp_write_currency_rate_rec IS
        
        CURSOR c_cur_rate IS
                SELECT season_year,season_type,currency_code,uk_exchange_rate,h_uk_exchange_rate
                FROM currency_rate ;

        ls_data    varchar2(100);
        first_time boolean := TRUE;
BEGIN

        v_statement_no := 182 ;
        FOR cur_rate_rec in c_cur_rate  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[CRT]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data :=  cur_rate_rec.season_year || chr(9) || cur_rate_rec.season_type || chr(9) ||
                       cur_rate_rec.currency_code || chr(9) || cur_rate_rec.uk_exchange_rate  || chr(9) ||
                       cur_rate_rec.h_uk_exchange_rate ;
           v_statement_no := 192 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_currency_rate_rec ;
------------------------------------------------------------------------------------------------

PROCEDURE sp_write_expense_rec IS
        
        CURSOR c_exp IS
                SELECT expense_code,description,to_char(amended_date_time,'dd-mm-yy hh24:mi:ss') amended_date_time,amended_user_id,amended_process
                FROM expense ;
        ls_data    varchar2(150);
        first_time boolean := TRUE;    
BEGIN
        v_statement_no := 142 ;
        FOR exp_rec in c_exp  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[EXP]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data := exp_rec.expense_code || chr(9) || exp_rec.description || chr(9) || 
                      exp_rec.amended_date_time || chr(9) || exp_rec.amended_user_id || chr(9) || exp_rec.amended_process ;
           v_statement_no := 147 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_expense_rec ;


------------------------------------------------------------------------------------------------

PROCEDURE sp_write_languages_rec  IS

    CURSOR c_lan IS
        SELECT language_code,description, to_char(amended_date_time,'dd-mm-yy hh24:mi:ss') amended_date_time,amended_user_id,amended_process 
        FROM languages ;

    ls_data    varchar2(150);
    first_time boolean := TRUE;
BEGIN
        v_statement_no := 200 ;
        FOR lan_rec in c_lan  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[LAN]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data := lan_rec.language_code || chr(9) || lan_rec.description || chr(9) || lan_rec.amended_date_time || 
                      chr(9) || lan_rec.amended_user_id || chr(9) || lan_rec.amended_process ;

           v_statement_no := 205 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_languages_rec ;

------------------------------------------------------------------------------------------------

PROCEDURE sp_write_reason_rec  IS

    CURSOR c_rsn IS
        SELECT reason_code,language_code,description,to_char(amended_date_time,'dd-mm-yy hh24:mi:ss') amended_date_time,amended_user_id,amended_process,business_rule 
        FROM reason ;

    ls_data    varchar2(150);
    first_time boolean := TRUE;
BEGIN
        v_statement_no := 202 ;
        FOR rsn_rec in c_rsn  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[RSN]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data := rsn_rec.reason_code || chr(9) || rsn_rec.language_code || chr(9) || rsn_rec.description ||
                      chr(9) || rsn_rec.amended_date_time || chr(9) || rsn_rec.amended_user_id || chr(9) || rsn_rec.amended_process || chr(9) || rsn_rec.business_rule;

           v_statement_no := 208 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_reason_rec ;


------------------------------------------------------------------------------------------------

PROCEDURE sp_write_location_rec  IS
            
        CURSOR c_loc IS
            SELECT  location_code,description,language_code,to_char(amended_date_time,'dd-mm-yy hh24:mi:ss') amended_date_time,
                    amended_user_id,amended_process,country_code,country_description,ccy_code
            FROM location ;
 

        ls_data    varchar(150) ;
        first_time boolean := TRUE;

BEGIN
           v_statement_no := 136 ;
        FOR loc_rec in c_loc  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[LOC]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
          ls_data := loc_rec.location_code || chr(9) || loc_rec.description || chr(9) || loc_rec.language_code || chr(9) ||
                     loc_rec.amended_date_time || chr(9) || loc_rec.amended_user_id || chr(9) ||  loc_rec.amended_process ||
                     chr(9) || loc_rec.country_code ||  chr(9) || loc_rec.country_description || chr(9) || loc_rec.ccy_code  ;
           v_statement_no := 142 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;


END  sp_write_location_rec;

------------------------------------------------------------------------------------------------
PROCEDURE sp_write_group_rec  IS

    CURSOR c_grp IS
        SELECT property_group_code,description,to_char(amended_date_time,'dd-mm-yy hh24:mi:ss') amended_date_time,amended_user_id,amended_process,aptos_n_code FROM property_group ; 

       ls_data    varchar2(150);
       first_time boolean := TRUE;
BEGIN
        v_statement_no := 258 ;
        FOR grp_rec in c_grp  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[GRP]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data := grp_rec.property_group_code || chr(9) || grp_rec.description || chr(9) || grp_rec.amended_date_time || chr(9) || grp_rec.amended_user_id || chr(9) || grp_rec.amended_process || chr(9) || grp_rec.aptos_n_code ;

           v_statement_no := 263 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_group_rec ;

------------------------------------------------------------------------------------------------
PROCEDURE sp_write_property_rec  IS

    CURSOR c_pro IS
        SELECT property_num,property_name,property_group_code,location_code,
               to_char(amended_date_time,'dd-mm-yy hh24:mi:ss') amended_date_time,amended_user_id,amended_process,aptos_n_code,
               gateway_code
        FROM property ;

        ls_data    varchar2(150);
        first_time boolean := TRUE;
BEGIN
        v_statement_no := 277 ;
        FOR pro_rec in c_pro  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[PRO]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data :=  pro_rec.property_num || chr(9) || pro_rec.property_name || chr(9) || pro_rec.property_group_code
                       || chr(9) || pro_rec.location_code || chr(9) || pro_rec.amended_date_time || chr(9)
                       || pro_rec.amended_user_id || chr(9) || pro_rec.amended_process || chr(9) || pro_rec.aptos_n_code 
                        || chr(9) ||   pro_rec.gateway_code;

           v_statement_no := 286 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_property_rec;

------------------------------------------------------------------------------------------------
PROCEDURE sp_write_otop_property_rec  IS

    CURSOR c_otop IS
        SELECT otop_accom_code,season, property_num 
        FROM otop_property ;
   
      ls_data    varchar2(50);
      first_time boolean := TRUE;
BEGIN
        v_statement_no := 277 ;
        FOR otop_rec in c_otop  LOOP
           IF first_time then 
               utl_file.put_line(pi_ref_file_handle,'[OTP]');
               first_time   := FALSE ;
           END IF ;
            -- create tab seperated string
           ls_data := otop_rec.otop_accom_code || chr(9) || otop_rec.season || chr(9) || otop_rec.property_num ;

           v_statement_no := 306 ;
           utl_file.put_line(pi_ref_file_handle,ls_data); 
        END LOOP ;

END sp_write_otop_property_rec;

------------------------------------------------------------------------------------------------
PROCEDURE sp_write_booking_rec(p_office_code IN CHAR)  IS
    
    CURSOR c_booking IS
       SELECT b.booking_seq_num,
              b.booking_ref,
              to_char(b.arrival_date,'dd-mm-yy hh24:mi:ss') arrival_date,
              to_char(b.departure_date,'dd-mm-yy hh24:mi:ss') departure_date,
              lead_passenger_name,
              no_of_adults,
              no_of_children,
              no_of_infants,
              duration,
              cancelled_flag,
              to_char(b.amended_date_time,'dd-mm-yy hh24:mi:ss')  amended_date_time,
              b.amended_user_id,
              b.amended_process,
              season,
              twin_centre_ind
        FROM booking b
        WHERE 
             b.extracted_date is null AND 
                EXISTS (select null from 
                 booking_accom ba, property, location, country_office_correlation coc
               WHERE b.booking_seq_num = ba.booking_seq_num AND 
                     ba.property_num = property.property_num  AND
                     property.location_code = location.location_code AND
                     location.country_code = coc.country_code AND
                     coc.office_code = p_office_code )
               FOR UPDATE OF b.extracted_date ;


    CURSOR c_booking_accom(ln_booking_seq_num Number) IS
       SELECT booking_seq_num,booking_accom_seq_num,property_num,accrual_amt,to_char(accom_start_date,'dd-mm-yy hh24:mi:ss') accom_start_date,
             to_char(amended_date_time,'dd-mm-yy hh24:mi:ss') amended_date_time ,amended_user_id,amended_process,accrual_ccy_code,os_amt,
             multi_invoice_ind,otop_accom_code,held_code,accrual_revised_by_amt
       FROM booking_accom 
       WHERE booking_seq_num =  ln_booking_seq_num     ;

        ls_data  varchar2(1000);
        first_time boolean := TRUE;
BEGIN
        FOR bking_rec in c_booking  LOOP
          v_statement_no := 386 ;
          -- create tab seperated string
          ls_data := 'B' || chr(9) || bking_rec.booking_seq_num || chr(9) || bking_rec.booking_ref || chr(9) || bking_rec.arrival_date 
                      || chr(9) || bking_rec.departure_date || chr(9) || bking_rec.lead_passenger_name || chr(9) || bking_rec.no_of_adults
                      || chr(9) || bking_rec.no_of_children || chr(9) || bking_rec.no_of_infants || chr(9) || bking_rec.duration || chr(9) || bking_rec.cancelled_flag  || chr(9) || bking_rec.amended_date_time || chr(9) || bking_rec.amended_user_id || chr(9) || bking_rec.amended_process
                      || chr(9) || bking_rec.season || chr(9) || bking_rec.twin_centre_ind ;

          v_statement_no := 388 ;
          utl_file.put_line(pi_boo_file_handle,ls_data); 

            FOR bking_accom_rec in c_booking_accom(bking_rec.booking_seq_num) LOOP
                v_statement_no := 397 ;
                ls_data := 'BA' || chr(9) || bking_accom_rec.booking_seq_num || chr(9) || bking_accom_rec.booking_accom_seq_num || chr(9) || bking_accom_rec.property_num
                      || chr(9) || bking_accom_rec.accrual_amt || chr(9) || bking_accom_rec.accom_start_date || chr(9) || bking_accom_rec.amended_date_time
                      || chr(9) || bking_accom_rec.amended_user_id || chr(9) || bking_accom_rec.amended_process || chr(9) || bking_accom_rec.accrual_ccy_code
                      || chr(9) || bking_accom_rec.os_amt || chr(9) || bking_accom_rec.multi_invoice_ind || chr(9) || bking_accom_rec.otop_accom_code
                      || chr(9) || bking_accom_rec.held_code || chr(9) || bking_accom_rec.accrual_revised_by_amt    ;
                v_statement_no := 402 ;
                utl_file.put_line(pi_boo_file_handle,ls_data); 
             END LOOP ;
          
          UPDATE booking 
          SET extracted_date = sysdate
          WHERE CURRENT OF c_booking ;

        END LOOP ;

END sp_write_booking_rec;
------------------------------------------------------------------------------------------------

END  pkg_create_ref_book_file ;

/

exit 
