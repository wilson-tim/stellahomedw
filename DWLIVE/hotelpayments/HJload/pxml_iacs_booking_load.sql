CREATE OR REPLACE Package pkg_xml_to_iacs_booking_load as
        procedure insert_into_error_table(filename varchar2,data_record varchar2,description1 varchar2,code varchar2,description2 varchar2);
        procedure booking_load;
        procedure bookingaccom_load;
        Procedure clear_bkg_temp_tables;

End pkg_xml_to_iacs_booking_load;

/
show err

-------------------------------------------------------------------------------------------

CREATE OR REPLACE Package body pkg_xml_to_iacs_booking_load as

--Version 1.0   Initial Version(JR) - This Package loads data from xml data files (supplied by
--                                     Hayes and Jarvis) into iacs reference tables(location,property,otop_property)
--  1.1          JR - (2/7/02)      - Changed in season- replaces  'C' for 'S' (Summer) and 'D' for 'W'(Winter) 

v_filename      varchar2(30);
v_error_message1 varchar2(100);
v_error_message2 varchar2(100);
v_error_code     varchar2(20);
--v_exist                Float ;

v_file_log       utl_file.file_type;
v_logging        boolean := TRUE;
v_statement      number;
v_data_record    varchar2(100);
li_updatecount   number;
v_severity       Number ;

--curnode sys.xmldom.DOMNode;

-------------------------------------------------------------------------------------------------

PROCEDURE f_log (v_null varchar2) IS
       -- function used to write a performance log to file in milliseconds
v_secs          number(30);

        BEGIN
        IF v_logging  THEN
               SELECT hsecs into v_secs FROM v$timer;
               utl_file.put_line(v_file_log,'S:'||v_statement||' '||to_char(sysdate,'yy-mon-dd hh24:mi:ss')||' '||v_secs);
        END IF;

        END f_log; -- end function

-------------------------------------------------------------------------------------------------

Procedure insert_into_error_table(filename varchar2,data_record varchar2,description1 varchar2,code varchar2,description2 varchar2) is

v_mess1  varchar2(100);
v_code   varchar2(20);
v_datetime Date := sysdate;

Begin

-- parameter1 is used as a filename
-- parameter2 is used as a data record
-- parameter3 are not used

        Insert into iacs.iacs_general_error
        Values (v_datetime,filename,data_record,'',description1,code,description2,v_severity);

--      Commit;

        Exception When others then
          dbms_output.put_line('Error occured while inserting into iacs.iacs.general table');
          dbms_output.put_line('Error code is :' || sqlcode ||' Error message is : ' || sqlerrm);
          v_mess1 := sqlerrm;
          v_code  := sqlcode;
          v_severity := 5;
--        Rollback;
          Insert into iacs.iacs_general_error
          Values (v_datetime,'PROGRAM GENERATED ERROR','WHILE INSERTING INTO IACS_GENERAL_ERROR TABLE','',v_mess1,v_code,'',v_severity);
  --        Commit;

End insert_into_error_table ;
-------------------------------------------------------------------------------------------------

Procedure booking_load is

--v_booking_row         iacs.booking%ROWTYPE;
v_booking_seq_num       iacs.booking.booking_seq_num%TYPE;
v_bookingcount          number  := 0;

Cursor c_booking is
        Select booking_ref,arrival_date,departure_date, lead_passenger_name,
               no_of_adults, no_of_children, no_of_infants,duration, cancelled_flag,
 decode(substr(rtrim(season),1,1),'C','S','D','W',substr(rtrim(season),1,1))|| substr(rtrim(season),2,
3) season  , twin_centre_ind
        From iacs.temp_xml_booking  ;

Begin

For c_booking_row IN c_booking Loop

Begin

        Update iacs.booking
                        Set arrival_date        = c_booking_row.arrival_date,
                            departure_date      = c_booking_row.departure_date,
                            lead_passenger_name = c_booking_row.lead_passenger_name,
                            no_of_adults        = c_booking_row.no_of_adults,
                            no_of_children      = c_booking_row.no_of_children,
                            no_of_infants       = c_booking_row.no_of_infants,
                            duration            = c_booking_row.duration,
                            cancelled_flag      = c_booking_row.cancelled_flag,
                            amended_date_time   = sysdate,
                            amended_user_id     = user,
                            amended_process     = 'XML LOAD',
                            twin_centre_ind     = c_booking_row.twin_centre_ind,
                            extracted_date      = Null,         -- Extract routine should pick this up
                            booking_source      = 'H'           -- 'H' for Hays and Jarvis booking
                        Where booking_ref       = c_booking_row.booking_ref and
                              season            = c_booking_row.season ;

            li_updatecount := SQL%ROWCOUNT ;

            If li_updatecount = 0 then

-- Generate Booking Sequence No.
        select iacs.sq_iacs_booking_seq_no.NextVal into v_booking_seq_num from dual;

--   dbms_output.put_line('booking seq no' || v_booking_seq_num);

                Insert into iacs.booking
                Values (v_booking_seq_num,
                        c_booking_row.booking_ref,
                        c_booking_row.arrival_date,
                        c_booking_row.departure_date,
                        c_booking_row.lead_passenger_name,
                        c_booking_row.no_of_adults,
                        c_booking_row.no_of_children,
                        c_booking_row.no_of_infants,
                        c_booking_row.duration,
                        c_booking_row.cancelled_flag,
                        sysdate,
                        user,
                        'XML LOAD',
                        c_booking_row.season,
                        c_booking_row.twin_centre_ind,
                        NULL,                   --extracted_date
                        'H'
                        );
            End if;
            v_bookingcount := v_bookingcount + 1  ;

        Exception
                When others then
                 dbms_output.put_line('Error at Booking Reference/Season : ' || c_booking_row.booking_ref ||'/' || c_booking_row.season || ' and Error Code is : ' || sqlcode);
                 dbms_output.put_line('Error Message : ' || sqlerrm);
                v_filename              := 'booking.xml';
                v_data_record           := 'Booking Ref :' || c_booking_row.booking_ref||' Season:'||c_booking_row.season ;
                v_error_code            := sqlcode;
                v_error_message1        := substr(sqlerrm,1,100);
                v_error_message2        := substr(sqlerrm,101,200);
                v_severity              := 5;
--              Rollback;
                insert_into_error_table(v_filename,v_data_record,v_error_message1,v_error_code,v_error_message2);

         End ;


End loop;

        Commit;


dbms_output.put_line(' NO. OF BOOKINGS SUCCESSFULLY LOADED : ' || v_bookingcount);

End booking_load;

------------------------------------------------------------------------------------------------------

Procedure bookingaccom_load is

--v_bookingaccom_row    iacs.booking_accom%ROWTYPE;
v_booking_seq_num       iacs.booking.booking_seq_num%TYPE;
--v_booking_ref         iacs.booking.booking_ref%TYPE;
--v_season              iacs.booking.season%TYPE;
v_booking_accom_seq_num iacs.booking_accom.booking_accom_seq_num%TYPE;

ls_bookaccom_logfile     varchar2(40) ;
li_bookingaccom_len      number;
v_bookingaccomcount      number  := 0;

Cursor c_bookingaccom is
        Select booking_ref,
 decode(substr(rtrim(season),1,1),'C','S','D','W',substr(rtrim(season),1,1))|| substr(rtrim(season),2,
3) season  ,property_num,accrual_amt,accom_start_date,
               trim(accrual_ccy_code) accrual_ccy_code,otop_accom_code
        from iacs.temp_xml_booking_accom ;

Begin


ls_bookaccom_logfile := 'bookingaccom.txt';
v_file_log := utl_file.fopen('/data/hotelpayments/export',ls_bookaccom_logfile,'w') ;

v_statement := 217;
f_log(null);

For c_bookingaccom_row IN c_bookingaccom Loop

Begin

v_statement := 238 ;
f_log(null);

/*  Don't load any accoms which is having dummy property code,
    TMS should assign proper property num to load into Iacs.
    Log this into table and send e mail to support

    Also if Accrual Amount is 0 continue  load this accom as there is
    some error in  calculation at H and J
*/

If c_bookingaccom_row.property_num <> 999990  then

v_statement := 299;
f_log(null);

        Select booking_seq_num
        Into   v_booking_seq_num
        From iacs.booking
        Where booking_ref = c_bookingaccom_row.booking_ref and
              season      = c_bookingaccom_row.season ;
v_statement := 270;
f_log(null);

-- Download into iacs sql anywhere database fails if currency code is null so default it to ???

        If (c_bookingaccom_row.accrual_ccy_code is null) or (c_bookingaccom_row.accrual_ccy_code = '') then
           c_bookingaccom_row.accrual_ccy_code := '???';
        End if;

        Update iacs.booking_accom
                Set property_num           = c_bookingaccom_row.property_num,
                    accrual_amt            = c_bookingaccom_row.accrual_amt,
                    amended_date_time      = sysdate,
                    amended_user_id        = user,
                    amended_process        = 'XML LOAD',
                    accrual_revised_by_amt = accrual_revised_by_amt + (c_bookingaccom_row.accrual_amt -  accrual_amt),
                    os_amt                 = os_amt + (c_bookingaccom_row.accrual_amt -  accrual_amt),
                    extracted_date         = NULL
                Where booking_seq_num      = v_booking_seq_num and
                    otop_accom_code        = c_bookingaccom_row.otop_accom_code and
                    accom_start_date       = c_bookingaccom_row.accom_start_date and
                    accrual_ccy_code       = c_bookingaccom_row.accrual_ccy_code ;

         li_updatecount := SQL%ROWCOUNT ;

v_statement := 290;
f_log(null);

  If li_updatecount = 0 then

-- Get the Last accom seq number
       Select max(booking_accom_seq_num) + 1
       Into v_booking_accom_seq_num
       From iacs.booking_accom
       Where booking_seq_num    = v_booking_seq_num  ;

v_statement := 301;
f_log(null);

       If (v_booking_accom_seq_num  is null) then
                 v_booking_accom_seq_num  := 1;
       End if;

        Insert into iacs.booking_accom
        Values (v_booking_seq_num,
                v_booking_accom_seq_num ,
                c_bookingaccom_row.property_num,
                c_bookingaccom_row.accrual_amt,
                c_bookingaccom_row.accom_start_date,
                sysdate,
                user,
                'XML LOAD',
                c_bookingaccom_row.accrual_ccy_code,
                c_bookingaccom_row.accrual_amt,          -- os amt and accrual amt is same while insert
                NULL,                                        -- multi_invoice_ind
                c_bookingaccom_row.otop_accom_code,
                NULL,                -- held_code
                0,                   -- accrual_revised_by_amt
                NULL,                -- extracted_date
                NULL,                -- exclude_payment_ind,
                NULL);               -- final_otop_accom_code

       End if;

      v_bookingaccomcount := v_bookingaccomcount + 1;

v_statement := 330;
f_log(null);

  Else  -- Booking accom with property num 999990

v_statement := 370;
f_log(null);

        -- Log into iacs_general_error table
           v_filename           := 'bookingaccom.xml';
           v_data_record        := substr('Booking Ref/Season'||c_bookingaccom_row.booking_ref||'/'||c_bookingaccom_row.season||' Booking seq No:'||v_booking_seq_num ||
                                   ' Otop Accom Cd:'||c_bookingaccom_row.otop_accom_code|| ' Accom St Dt:'||c_bookingaccom_row.accom_start_date||
                                   ' Ccy Cd:'|| c_bookingaccom_row.accrual_ccy_code ,1, 100);
           v_error_code         := 'Load Error';
           v_error_message1     := ' Property Num 999990 will not be loaded into Iacs.';
           v_error_message2     := '';
           v_severity           := 1;
           insert_into_error_table(v_filename,v_data_record,v_error_message1,v_error_code,v_error_message2);

  End if ; -- ignore loading dummy property code 999990

        Exception
                When others then
                dbms_output.put_line('Booking accom seq num/otopaccomcode/start dt/ccy :'||v_booking_seq_num ||'/'||
                v_booking_accom_seq_num || '/'||c_bookingaccom_row.otop_accom_code||'/'||c_bookingaccom_row.property_num || '/'||
                c_bookingaccom_row.accom_start_date||'/'||c_bookingaccom_row.accrual_ccy_code );
                dbms_output.put_line('Error at Booking Reference/season : ' || c_bookingaccom_row.booking_ref || '/'|| c_bookingaccom_row.season || ' and Error Code is : ' || sqlcode);
                dbms_output.put_line('Error Message : ' || sqlerrm);
                v_filename              := 'bookingaccom.xml';
                v_data_record           := 'Booking Ref'||c_bookingaccom_row.booking_ref||' Season:'||c_bookingaccom_row.season||' Booking seq Num :'||v_booking_seq_num ||
           ' Otop Accom Cd:'||c_bookingaccom_row.otop_accom_code ;
                v_error_code            := sqlcode;
                v_error_message1        := substr(sqlerrm,1,100);
                v_error_message2        := substr(sqlerrm,101,200);
--              Rollback;
                v_severity              := 5;
                insert_into_error_table(v_filename,v_data_record,v_error_message1,v_error_code,v_error_message2);

   End;

End Loop;

dbms_output.put_line(' NO. OF BOOKING ACCOMS SUCCESSFULLY LOADED : ' || v_bookingaccomcount);


   Commit;

End bookingaccom_load;

-------------------------------------------------------------------------------------------------
Procedure clear_bkg_temp_tables is
Begin
         delete from iacs.temp_xml_booking ;
         delete from iacs.temp_xml_booking_accom ;
         commit;

End clear_bkg_temp_tables ;

-------------------------------------------------------------------------------------------------

End pkg_xml_to_iacs_booking_load;

/
show err
