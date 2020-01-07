-- 1 Leigh Ashton 4/10/99         First version

-- 1.0 Leigh Ashton 1/12//99        Live version

-- 1.1 Leigh  10/12/99              Fixed to allow amount revision

-- 1.2 Leigh  13/12/99              Added union to main cursor to bring back zero accruals where no accrual

-- 1.3 Leigh  14/02/00              Use otop_accom_sale not otop_inventory_sale. Also exclude header accommodations

-- 1.4 Leigh  6/3/00                Use accom_fin_detail instead to calc ccy and otop_accom loop. Change to differen fin calc lines

-- 1.5 Leigh  30/3/00               Change season processing to allow for post W99 seasons.

-- 1.6 Leigh  23/5/00               Allow change of contract currency to create new booking_accom

-- 1.7 Leigh  28/5/00               Change reset_These cursor to reset those accruals whose ccy has changed (e.g. merlin contract has changed ccy).

-- 1.8 Leigh  28/9/00               Change accruals calc from line 67 to line 68 after DAS implementation

-- 1.9 Leigh  24/10/00              Change accruals calc to include line 61 - tax after DAS implementation

-- 1.10 Leigh 28/11/00              Update extracted_date to null when update booking_Accom accrual
-- 1.11 Leigh 20/12/00              Some new pl/sql blocks added to end so ensure accruals kept more up-to-date 
-- 1.12 Leigh 31/5/01               Set up dummy properties for Bodrum and Cyprus


-- iacs booking / accrual extract from dwhse to load iacs schema tables



-- extract all bookings and associated financial detail data for all bookings that have changed since last extract

-- hotel_payment_control provides a to-do list of those we have now extracted to hotel payments since last time

-- note that a booking can be extracted then re-extracted again if it's financial details change

-- hotel_payment_control is populated in fcalc_drive.sql when accomodation related lines change



-- this is fired from iacsload.ksh



-- IMPORTANT!! NOTE THAT the property and location updates in iacsload.ksh should take place first so that the link between otop_accom_codes and property_num / property_refs is made

-- i.e. in statement 71



-- see the iacs techspec.doc for details on how this extract/load works





set serveroutput on size 1000000

--set serveroutput off



DECLARE 



        v_logging               boolean := TRUE;

        v_include_missing_accruals      CHAR(1) :='Y'; -- to use second part of main cursor (union) or not

        v_statement             number :=1;

        v_secs                  number(30);

        v_season                char(5) := ' ';

        v_book_ref              booking.booking_reference_no%TYPE :=0;

        v_season_type           booking.season_type%TYPE;

        v_season_year           booking.season_year%TYPE;

        v_details_updated_date  financial_detail.details_updated_date%TYPE;

        v_os_amt                financial_detail.revenue_or_cost%TYPE;

        v_os_amt61              financial_detail.revenue_or_cost%TYPE;

        v_os_amt64              financial_detail.revenue_or_cost%TYPE;

        v_os_amt66              financial_detail.revenue_or_cost%TYPE;



        v_os_amt68              financial_detail.revenue_or_cost%TYPE;

        v_os_amt58              financial_detail.revenue_or_cost%TYPE;

        v_os_amt59              financial_detail.revenue_or_cost%TYPE;

        v_property_Num          accom_detail.data_warehouse_accom_code%TYPE;

        v_ex_rate               currency_rate.uk_exchange_rate%TYPE;

        v_bkac_records_written  number(9) := 0;

        v_bk_records_written    number(9) := 0;

        v_rowtotal              number(9) := 0;

        v_file_handle           utl_file.file_type;

        v_file_log              utl_file.file_type;

        ls_booking_accom_rec    varchar2(800); -- 800 should be more than enough

        ls_booking_rec          varchar2(800); -- 800 should be more than enough

        v_contract_ccy          financial_detail.currency_code%TYPE;

        v_cust                  customer.surname%TYPE;

        ls_ref_filename         varchar2(40);

        ls_ref_logfile         varchar2(40);

        v_booking_seq_num       number(20);

        v_acc_loop              number(9) :=0;

        v_guarantee_type_code   char(1);

        v_num_bkac_ins          number(9) :=0;

        v_num_bk_ins            number(9):=0;

        v_no_otop               number(9):=0;

        v_num_bkac_upd          number(9):=0;

        v_num_bk_upd            number(9):=0;

        v_count_missing_accruals number(9) :=0;

        v_otop_country_code     resort_location.country_code%TYPE;

        v_count_afdloop         number(9):= 0;

        v_count_noafd   number(9):= 0;

        v_booking_accom_seq_num number(17) :=0;



-- perform all this for each season that is set to Y in enabled_season table

CURSOR SEASON_TO_EXTRACT IS

SELECT season_Type, season_year

FROM iacs.enabled_season

WHERE iacs_extract_enabled = 'Y';







-- main cursor driven by season_cursor

-- should just bring back one row per booking



CURSOR MAIN_CURSOR (a_season_year char, a_season_type char) IS

SELECT /*+ INDEX(bfd BASFD_PK)  INDEX(booking BKING_PK)*/ 

        h.booking_reference_no, h.season_Type season_type, h.season_year season_year,

        bfd.details_updated_date,

        booking.holiday_departure_date hol_departure_date,

        booking.holiday_return_date hol_return_date,

        nvl(bfd.no_of_adults,0) no_of_adults, 

        nvl(bfd.no_of_children,0) no_of_children, 

        nvl(bfd.no_of_infants,0) no_of_infants, 

        nvl(booking.duration,0) duration,

        decode(substr(booking.booking_status_code,1,3),'CNX','Y','N') cancelled_ind ,

        h."SEASON_TYPE"||substr( h."SEASON_YEAR",3,2) season ,

        decode(substr(booking.package_type_code,1,2),'MU','Y',null) twin_centre_ind 

FROM

                    iacs.hotel_payment_control h,

                    V_BASE_FINANCIAL_DETAIL bfd, 

                        booking 

WHERE 

 h.extracted_date is null and                   -- not extracted yet/before

 h.booking_reference_no = bfd.booking_reference_no and

 h.season_year = bfd.season_year  and 

 h.season_Type = bfd.season_Type and

 h.season_type = a_season_type and

 h.season_year = a_season_year and

 booking.booking_reference_no = bfd.booking_reference_no and

 booking.season_year = bfd.season_year  and

 booking.season_Type = bfd.season_Type 

-- next subquery to ensure that we exclude those bookings that were cancelled without 

-- entry of enough data

and exists (

SELECT null FROM otop_accom_sale ois

WHERE ois.season_type = h.season_Type

and ois.season_year = h.season_year

and ois.booking_Reference_no = h.booking_reference_no

AND  NOT ( alternative_service_type = 'HEA' AND allocation_type_code = 'N'))


and h.booking_reference_no = 565206
and h.season_type = 'W' and h.season_year = '2001'

---------------------------------------

---------------------------------------

UNION  --!!!!!!!!!!!!!!!!!!!!this added to allow accrual for those bookings with no fin details yet due to e.g. corr mapping problems

---------------------------------------

---------------------------------------

SELECT 

        booking.booking_reference_no, booking.season_Type season_type, booking.season_year season_year,

        to_date('1-JAN-1800','dd-mon-yyyy'),

        booking.holiday_departure_date hol_departure_date,

        booking.holiday_return_date hol_return_date,

        0 no_of_adults, 

        0 no_of_children, 

        0 no_of_infants, 

        nvl(booking.duration,0) duration,

        decode(booking.booking_status_code,'CNX','Y','N') cancelled_ind ,

        booking."SEASON_TYPE"||substr( booking."SEASON_YEAR",3,2) season ,

        decode(substr(booking.package_type_code,1,2),'MU','Y',null) twin_centre_ind 

FROM

        booking     /* this is the dataw owned booking table */

WHERE

        v_include_missing_accruals = 'Y' and
 booking.booking_reference_no = 565206
and booking.season_type = 'W' and booking.season_year = '2001'
and
        booking.season_type = a_season_type and

        booking.season_year = a_season_year and

         EXISTS (  /* there is a valid otop_accom_sale */

                SELECT null FROM otop_accom_sale ois   

                WHERE ois.season_type = booking.season_Type

                and ois.season_year = booking.season_year

                and ois.booking_Reference_no = booking.booking_reference_no

                AND  NOT ( alternative_service_type = 'HEA' AND allocation_type_code = 'N'))

        AND NOT EXISTS

                ( SELECT null from financial_detail fd

                WHERE fd.season_type = booking.season_Type

                and fd.season_year = booking.season_year

                and fd.booking_Reference_no = booking.booking_reference_no

                and revenue_line_code between 58 and 68) /* no accomodation accrual */

        and not exists

                (select null from iacs.booking b    

                where booking.season_type = substr(b.season,1,1)

                and booking.season_year = (decode(substr(b.season,2,2),'99','19','20')||substr(b.season,2,2))

                and booking.booking_reference_no = b.booking_ref) /* has not been extracted before */ 

;







-- for each booking, need to get property details (may be for more than one property e.g. multicentres)

-- integrity problem with details_updated_date mean that it's best to use max, not do a join to fin_detail



CURSOR accom_sale_cursor (a_season_year char, a_season_type char) is

         SELECT otop_accom_code,

         cycle_start_date, season_type, season_year   /* have to do min in case holiday is split dates e.g. they go off touring for a couple of daya then come back to same hotel */

        FROM otop_accom_sale ois

        WHERE   ois.booking_reference_no = v_book_ref

        and ois.season_type = a_season_type 

        and ois.season_year = a_season_year 

        AND  NOT ( alternative_service_type = 'HEA' AND allocation_type_code = 'N')

        and ois.details_updated_date =

                 (SELECT max(ois2.details_updated_date)

                FROM otop_accom_Sale ois2

                WHERE ois.booking_reference_no = ois2.booking_Reference_no

                and ois.season_type = ois2.season_type

                and ois.season_year = ois2.season_year)

;





/* this is third cursor, effectively gives one accrual per contract ccy per accom of a booking  */

/* most of the time there will only be one row here */

CURSOR accom_fin_detail_ccy (a_season_year CHAR, a_season_type CHAR, a_book_ref NUMBER, 

                        a_otop_accom_code CHAR, a_cycle_start_date DATE) is

         SELECT currency_code, 

                 nvl(sum(-1 * decode(afd.REVENUE_LINE_CODE,59,nvl(round(afd.REVENUE_OR_COST_LOCAL,2),0),0)),0) cost_line59,  

                 nvl(sum(-1 * decode(afd.REVENUE_LINE_CODE,68,nvl(round(afd.REVENUE_OR_COST_LOCAL,2),0),0)),0) cost_line68,

                 nvl(sum(-1 * decode(afd.REVENUE_LINE_CODE,61,nvl(round(afd.REVENUE_OR_COST_LOCAL,2),0),0)),0) cost_line61

                FROM accom_financial_detail afd

                WHERE afd.season_year = a_season_year

                AND afd.season_type = a_season_Type

                AND afd.booking_reference_no = a_book_ref

                AND afd.cycle_start_date = a_cycle_start_date

                AND afd.otop_accom_code = a_otop_accom_code

                GROUP BY booking_reference_no, otop_accom_code, cycle_start_date, season_type, season_year, currency_code;











PROCEDURE f_log (v_null varchar2) IS

        -- function used to write a performance log to file in milliseconds

        BEGIN



        IF v_logging AND (mod(v_rowtotal,50) = 0 or v_rowtotal < 50) THEN 

                SELECT hsecs into v_secs FROM v$timer;

                utl_file.put_line(v_file_log,'S:'||v_statement||' '||to_char(sysdate,'yy-mon-dd hh24:mi:ss')||' '||v_secs);

        END IF;

END f_log; -- end function





-------------------------------------------------------------------------

BEGIN -- main pl/sql block

-------------------------------------------------------------------------



v_statement :=10;

ls_Ref_Filename := 'bookext1.txt';

ls_Ref_logfile := 'booklog.txt';

v_file_handle := utl_file.fopen('/data/hotelpayments/export',ls_ref_filename,'w') ;

--v_file_log := utl_file.fopen('/home/dw/jyoti',ls_ref_logfile,'w') ;

v_file_log := utl_file.fopen('/data/hotelpayments/export',ls_ref_logfile,'w') ;

--v_file_handle := utl_file.fopen('/home/dw/jyoti',ls_ref_filename,'w') ;





f_log(null);



v_statement :=20;

FOR seas_cur in season_to_extract LOOP



        v_season_type := seas_cur.season_type;

        v_season_year := seas_cur.season_year;

        dbms_output.put_line('starting loading season:'||v_season_Type||v_season_year);



        v_statement :=30;

        f_log(null);





        FOR c1 in main_cursor(v_season_year, v_season_type) LOOP



                f_log(null);



                v_season := c1.season_type||c1.season_year;

                v_book_Ref := c1.booking_reference_no;

                --dbms_output.put_line('booking:'||v_book_ref||'c:'||c1.cancelled_ind);

                v_details_updated_date := c1.details_updated_date;



                IF v_details_updated_date = '1-JAN-1800' THEN

                        v_count_missing_accruals := v_count_missing_accruals +1;

                END IF;



                v_os_amt := 0;



                -- for each booking, get associated details, and get all accoms under this booking



                f_log(null);

                v_statement :=50;

                -- get customer name for booking rec

                -- assume the first pass in sequence is the lead



                BEGIN



                SELECT  upper(nvl(cust.surname,'UNKNOWN')||' '||nvl(cust.initials,'')||' '||nvl(cust.title,''))

                        into v_cust

                FROM customer_reservation cres, customer cust

                WHERE c1.season_year = cres.season_year 

                        and c1.season_Type = cres.season_Type 

                        and cust.customer_reference_no  = cres.customer_reference_no 

                        /*      and cust.customer_type = 'LEAD' */ -- can't use this flag - it is unreliable

                        and cres.passenger_sequence_no  = 1

                        and cres.booking_Reference_no = c1.booking_reference_no

                        and rownum =1;  -- should only ever be one row anyway, this will prevent too many rows



                f_log(null);



                EXCEPTION

                WHEN no_data_found THEN

                        v_cust := 'UNKNOWN';

                END; -- customer block



                v_statement := 60;



                v_acc_loop := 0; -- reset each time we go into the accom loop



                f_log(null);

                v_booking_accom_seq_num := 0;



                FOR acc IN accom_sale_cursor(v_season_year, v_season_type) LOOP -- for each accom loop



                        -- for each of following rows write a booking_Accom row

                        -- we are accruing at property level so need one line per property......

                        -- but note that at the moment we cannot split cost amts per property. this will change when financial_detail table structure is changed

                        v_statement :=70;





                        f_log(null);



                        -- get property stuff - (because need property_num)

                        BEGIN

                        BEGIN

                                v_statement :=80;

                                -- iacs.otop_property table is populated in propertyext.sql 



                                SELECT  property_num

                                INTO v_property_num

                                FROM iacs.otop_property ad

                                WHERE ad.otop_accom_code = acc.otop_accom_code

                                        and ad.season = c1.season;

                        EXCEPTION

                                WHEN NO_DATA_FOUND THEN

                                        -- set up a dummy property_num for this accrual so it can still be paid in resort

                                        -- assign a dummy property_Num according to the country that this booking applies to so that when bookings are split

                                        --  in iacsextract.ksh to each office

                                        BEGIN

                                                v_statement :=90;

                                                f_log(null);

                                                SELECT country_code

                                                        into v_otop_country_code

                                                FROM resort_location rl, accom_detail ad

                                                WHERE ad.season_type = acc.season_type

                                                AND ad.season_year = acc.season_year

                                                AND ad.otop_accom_code = acc.otop_accom_code

                                                AND ad.resort_location_code = rl.resort_location_code

                                                AND ad.season_type = rl.season_type

                                                AND ad.season_year = rl.season_year;



                                                IF v_otop_country_code in ('ES','PT') THEN

                                                        -- Spain or Portugal so set that dummy property_num

                                                        v_property_num := 999999;

                                                        --dbms_output.put_line('Spain, bking:'||c1.booking_reference_no||'otop_accom'||acc.otop_accom_code);
																ELSIF v_otop_country_code = 'TR' THEN
                                                        -- Turkey so set that dummy property_num

                                                        v_property_num := 999998;
			

																ELSIF v_otop_country_code = 'CY' THEN
                                                        -- Cyprus so set that dummy property_num

                                                        v_property_num := 999997;
			

                                                ELSE 

                                                        v_property_num := 4932; -- dummy property "flight only - dummy contract"

                                                END IF;

                                        EXCEPTION

                                                when no_data_found THEN 

                                                        v_property_num := 4932; -- note that this means it will go to UK office only

                                                        dbms_output.put_line('No country found, bking:'||c1.booking_reference_no||'otop_accom'||acc.otop_accom_code);

                                        END;

                        END; -- select prop num                        



                        v_acc_loop  := v_acc_loop + 1;

                        v_booking_accom_seq_num := v_booking_accom_seq_num + 1;



                        -- now write the booking record (doing it here rather than outside the loop ensures don't get booking records without booking_accom records)

                        v_statement :=100;



                        f_log(null);



                        IF v_acc_loop = 1 THEN

                                -- only one booking record but may have multiple booking_accom records, so only do once

                                BEGIN

                                v_statement :=110;



                                f_log(null);

                                -- primary keys are oracle sequences

                                SELECT  iacs.sq_iacs_booking_seq_no.nextval

                                into v_booking_seq_num FROM dual;



                                INSERT INTO iacs.booking 

                                        (booking_seq_num,

                                        booking_ref , 

                                        arrival_date ,

                                        departure_date ,

                                        lead_passenger_name ,

                                        no_of_adults ,

                                        no_of_children ,

                                        no_of_infants ,

                                        duration,

                                        cancelled_flag,

                                        amended_date_time,

                                        amended_user_id,

                                        amended_process,

                                        season,

                                        twin_centre_ind,

                                        extracted_date)

                                VALUES

                                       (v_booking_seq_num,

                                        c1.BOOKING_REFERENCE_NO,

                                        c1.hol_departure_date,

                                        c1.hol_return_date,

                                        v_cust,

                                        c1.no_of_adults,

                                        c1.no_of_children,

                                        c1.no_of_infants,

                                        c1.duration,

                                        c1.cancelled_ind,

                                        sysdate,

                                        user,

                                        'bkgext ins1.4',

                                        c1.season,

                                        c1.twin_centre_ind,

                                        null);  



                                v_bk_records_written := v_bk_records_written +1;



                                EXCEPTION

                                        WHEN DUP_VAL_ON_INDEX THEN

                                        --dbms_output.put_line(' Dup val index on booking'); 

                                        -- note that this update takes place even if no changes in values

                                        v_statement :=115;

                                          UPDATE iacs.booking  

                                          SET arrival_date = c1.hol_departure_date,

                                              departure_date =  c1.hol_return_date,

                                              lead_passenger_name = v_cust,

                                              no_of_adults = c1.no_of_adults, 

                                              no_of_children = c1.no_of_children,

                                              no_of_infants = c1.no_of_infants,

                                              duration = c1.duration,

                                              cancelled_flag = c1.cancelled_ind,

                                              amended_date_time = sysdate,

                                              amended_user_id = user,

                                              amended_process = 'bkgext upd',

                                              twin_centre_ind = c1.twin_centre_ind,

                                              extracted_date = null    -- so that extract routine picks it up

                                          WHERE booking_ref = c1.BOOKING_REFERENCE_NO AND

                                                season = c1.season ;    



                                          v_num_bk_upd := v_num_bk_upd + 1;



                                          -- get keys to use in booking_Accom section below

                                          SELECT booking_seq_num 

                                          INTO v_booking_seq_num

                                          FROM iacs.booking

                                          WHERE booking_ref = c1.BOOKING_REFERENCE_NO AND

                                                season = c1.season ;    



                                        WHEN others THEN

                                          dbms_output.put_line(sqlerrm||' s:'||v_statement);

                                          dbms_output.put_line('bref:'||v_book_ref||' S:'||v_season);



                                END; -- end insert into booking block

                        END IF; -- if 1st in seq

                        v_statement :=117;

                        f_log(null);



                        v_count_afdloop := 0;

                        

                        -- create an accrual per contract ccy



                        FOR afdloop IN accom_fin_detail_ccy(v_season_year, v_season_type, c1.booking_reference_no, acc.otop_accom_code, acc.cycle_start_date) LOOP



                                BEGIN

                                v_statement :=120;

                                f_log(null);

                                v_count_afdloop := v_count_afdloop + 1;

                                v_booking_accom_seq_num := v_booking_accom_seq_num + 1;

                                v_os_amt := afdloop.cost_line59 + afdloop.cost_line68 + afdloop.cost_line61;



                                v_contract_ccy := afdloop.currency_code;



                                --  round amount figure to 0 if ccy is (ESP, ITL, GRD, PTE)

                                IF v_contract_ccy in ('ESP','ITL','GRD','PTE') THEN

                                    v_os_amt  := Round(v_os_amt);

                                END IF;



                                v_statement :=130;

                                f_log(null);



                                BEGIN



                                INSERT INTO iacs.booking_accom

                                        (booking_seq_num,

                                        booking_accom_seq_num,

                                        property_num,

                                        accrual_amt,

                                        accom_start_date,

                                        amended_date_time,

                                        amended_user_id,

                                        amended_process,

                                        accrual_ccy_code,

                                        os_amt,

                                        multi_invoice_ind,

                                        otop_accom_code,

                                        held_code,

                                        accrual_revised_by_amt)

                                VALUES

                                        (v_booking_seq_num,     -- otop_booking_no,   

                                        v_booking_accom_seq_num,    -- booking_accom_seq_num  

                                        v_property_num,         -- property_num

                                        v_os_amt,                       -- accrual original amt (same as outstanding amt until some invoices come in in iacs)

                                        acc.cycle_start_date,   -- accom_start_date 

                                        sysdate,

                                        user,

                                        'bkgext ins1.6',

                                        v_contract_ccy,

                                        v_os_amt,

                                        null, -- set in iacs

                                        to_number(acc.otop_accom_code),

                                        null,

                                        0);     

                               

                                v_num_bkac_ins := v_num_bkac_ins + 1;



                                EXCEPTION

                                WHEN DUP_VAL_ON_INDEX THEN

                                -- dbms_output.put_line(' Dup val index on booking_accom'); 

                                -- this booking already has a booking_accom for this property/start date/ccy so update existing....

                                -- set the accrual amt to the newly calculated one,

                                -- change the accrual_revised_by_amt by the change in accrual

                                -- increase the o/s amt by the change in accrual

                                  v_statement :=140;

                                  f_log(null);



                                  UPDATE iacs.booking_accom

                                  SET 

                                      accrual_amt            = v_os_amt,

                                      accom_start_date       = acc.cycle_start_date,

                                      amended_date_time      = sysdate,

				extracted_date = null,
                                      amended_user_id        = user,

                                      amended_process        = 'bkgext upd1.6',

                                      accrual_ccy_code       = v_contract_ccy,

                                      otop_accom_code        = to_number(acc.otop_accom_code), 

                                      property_num           = v_property_num,

                                      accrual_revised_by_amt = accrual_revised_by_amt + (v_os_amt - accrual_amt),

                                      os_amt                 = os_amt + (v_os_amt - accrual_amt)   -- BUT this should not overwrite the o/s amt in iacs db when interfaced, instead the o.s in iacs db should be altered by the change in accrual

                                  WHERE booking_seq_num = v_booking_seq_num  AND

                                        otop_accom_code = to_number(acc.otop_accom_code) AND

                                        accom_start_date = acc.cycle_start_date AND

                                        accrual_ccy_code = v_contract_ccy ;   

                          

                                  -- dbms_output.put_line(sql%rowcount||' rows updated:'||v_statement);

                                  v_num_bkac_upd := v_num_bkac_upd + sql%rowcount;





				  -- new section below for v1.6

                                  IF sql%rowcount = 0 THEN

                                    -- if no rows were updatd, may be because accrual ccy has changed (contract ccy has changed).

                                    -- so need to insert a new booking_accom (cannot update existing one because it may have had 

				    -- payments made against it in resort)

                                     v_statement :=142;

                                     f_log(null);



                                     INSERT INTO iacs.booking_accom

                                        (booking_seq_num,

                                        booking_accom_seq_num,

                                        property_num,

                                        accrual_amt,

                                        accom_start_date,

                                        amended_date_time,

                                        amended_user_id,

                                        amended_process,

                                        accrual_ccy_code,

                                        os_amt,

                                        multi_invoice_ind,

                                        otop_accom_code,

                                        held_code,

                                        accrual_revised_by_amt)

                                   VALUES

                                       (v_booking_seq_num,     -- otop_booking_no,

                                        v_booking_accom_seq_num +to_number( to_char(sysdate,'yyddd')),    -- booking_accom_seq_num, use sysdate just to ensure no dups

                                        v_property_num,         -- property_num

                                        v_os_amt,                       -- accrual original amt (same as outstanding amt until some invoices come in in iacs)

                                        acc.cycle_start_date,   -- accom_start_date

                                        sysdate,

                                        user,

                                        'bkgext ins1.6ccy',

                                        v_contract_ccy,

                                        v_os_amt,

                                        null, -- set in iacs

                                        to_number(acc.otop_accom_code),

                                        null,

                                        0);



                                    v_num_bkac_ins := v_num_bkac_ins + 1;



                               END IF;  -- if sql%rowcount was 0



                                WHEN others THEN

                                  dbms_output.put_line(sqlerrm||' s:'||v_statement);

                                  dbms_output.put_line('bref:'||v_book_ref||' S:'||v_season);

                                END; -- end of insert into booking_Accom block







                                v_statement :=150;

                                f_log(null);

                                -- utl_file.put_line(v_file_handle,ls_booking_accom_rec);   -- write record to file

                 



                                EXCEPTION

                                when no_data_found then

                                        --dbms_output.put_line('nodat,s:'||v_statement);

                                        --dbms_output.put_line('bref:'||v_book_ref||' S:'||v_season);

                                        null;

                                when dup_val_on_index then                      

                                        --dbms_output.put_line('dupval,s:'||v_statement);

                                        --dbms_output.put_line('bref:'||v_book_ref||' S:'||v_season);

                                        null;

                         

                                END; -- end of accom_financial_detail afdloop cursor block

                        END LOOP;   -- end of accom_financial_detail afdloop cursor loop



                        IF v_count_afdloop = 0 THEN

                        --  no accom_financial_detail rows (perhaps due to fincalcs error), need to create a zero accrual anyway so can be paid in iacs)

                                BEGIN

                                        v_count_noafd := v_count_noafd + 1;

                                        v_statement :=160;

                                        f_log(null);

                                        -- get the contract ccy



                                        SELECT /*+ INDEX(cac,PK_accor) */

                                        c.currency_code

                                        into v_contract_ccy

                                        FROM

                                        contract c, accom_correlation cac

                                        WHERE c.contract_reference_no = cac.contract_reference_no

                                        and   c.contract_version = cac.contract_version

                                        and cac.season_year = c1.season_year

                                        and cac.season_type = c1.season_type

                                        and cac.otop_accom_code = acc.otop_accom_code

                                        and cac.map_start_Date <= acc.cycle_start_date

                                        and cac.map_end_Date >= acc.cycle_start_date

                                        and rownum = 1; /* there can be more than one row but impossible to restrict to 1 because of inadequacies of data model at present */



                                EXCEPTION

                                WHEN no_data_found THEN

                                        v_contract_ccy := '???';

                                        --dbms_output.put_line('cnodat'||' s:'||v_statement||'bref:'||v_book_ref||' S:'||v_season);



                                END; -- ccy block

                                

                                v_os_amt :=0;

                                v_statement :=170;



                                f_log(null);

                                -- now insert the zero accrual



                                BEGIN



                                INSERT INTO iacs.booking_accom

                                        (booking_seq_num,

                                        booking_accom_seq_num,

                                        property_num,

                                        accrual_amt,

                                        accom_start_date,

                                        amended_date_time,

                                        amended_user_id,

                                        amended_process,

                                        accrual_ccy_code,

                                        os_amt,

                                        multi_invoice_ind,

                                        otop_accom_code,

                                        held_code,

                                        accrual_revised_by_amt)

                                VALUES

                                        (v_booking_seq_num,     -- otop_booking_no,   

                                        v_booking_accom_seq_num,             -- booking_accom_seq_num  

                                        v_property_num,         -- property_num

                                        v_os_amt,                       -- accrual original amt (same as outstanding amt until some invoices come in in iacs)

                                        acc.cycle_start_date,   -- accom_start_date 

                                        sysdate,

                                        user,

                                        'bkgext ins1.4nofd',

                                        v_contract_ccy,

                                        v_os_amt,

                                        null, -- set in iacs

                                        to_number(acc.otop_accom_code),

                                        null,

                                        0);     

                               

                                v_num_bkac_ins := v_num_bkac_ins + 1;



                                EXCEPTION

                                WHEN DUP_VAL_ON_INDEX THEN

                                -- dbms_output.put_line(' Dup val index on booking_accom'); 

                                -- this booking already has a booking_accom for this property/start date/ccy so update existing....

                                -- set the accrual amt to the newly calculated one,

                                -- change the accrual_revised_by_amt by the change in accrual

                                -- increase the o/s amt by the change in accrual

                                  v_statement :=180;

                                  f_log(null);



                                  UPDATE iacs.booking_accom

                                  SET 

                                      accrual_amt            = v_os_amt,

                                      accom_start_date       = acc.cycle_start_date,

                                      amended_date_time      = sysdate,

					extracted_date = null,
                                      amended_user_id        = user,

                                      amended_process        = 'bkgext updnofd',

                                      accrual_ccy_code       = v_contract_ccy,

                                      otop_accom_code        = to_number(acc.otop_accom_code), 

                                      property_num           = v_property_num,

                                      accrual_revised_by_amt = accrual_revised_by_amt + (v_os_amt - accrual_amt),

                                      os_amt                 = os_amt + (v_os_amt - accrual_amt)   -- BUT this should not overwrite the o/s amt in iacs db when interfaced, instead the o.s in iacs db should be altered by the change in accrual

                                  WHERE booking_seq_num = v_booking_seq_num  AND

                                        otop_accom_code = to_number(acc.otop_accom_code) AND

                                        accom_start_date = acc.cycle_start_date AND

                                        accrual_ccy_code = v_contract_ccy ;   

                          

                                  -- dbms_output.put_line(sql%rowcount||' rows updated:'||v_statement);

                                  v_num_bkac_upd := v_num_bkac_upd + sql%rowcount;

                                WHEN others THEN

                                  dbms_output.put_line(sqlerrm||' s:'||v_statement);

                                  dbms_output.put_line('bref:'||v_book_ref||' S:'||v_season);

                                END; -- end of insert into booking_Accom block





                

                        END IF; -- if no accom_financial_detail



                        v_statement :=190;

                        f_log(null);

                        END; -- end of accom cursor block



                END LOOP;   -- accom acc cursor loop end







                v_statement :=200;

                f_log(null);



                IF v_acc_loop = 0 THEN 

                        --dbms_output.put_line('no otis Bk:'||v_book_ref||' S:'||v_season);

                        v_no_otop := v_no_otop + 1;

                ELSE

                        -- set the control record to "extracted"

                        v_statement :=210;



                        UPDATE iacs.hotel_payment_control h

                        SET extracted_date = sysdate

                        WHERE  h.booking_reference_no = c1.booking_reference_no and 

                         h.season_year = c1.season_year  and 

                         h.season_Type = c1.season_Type;

                

                END IF;



                -- commit every 500 cycles so don't blow rollback segment

                IF mod(v_rowtotal / 500,1) = 0 THEN 

                        COMMIT;

                END IF;



                v_rowtotal := v_rowtotal + 1; -- count of all bookings processed through main cursor



                v_statement :=220;



        END LOOP; -- main c1 cursor





        v_statement :=230;

        dbms_output.put_line('finished loading season:'||v_season_Type||v_season_year);



END LOOP; -- season cursor



v_statement :=240;

f_log(null);



dbms_output.put_line('End of booking load at:'|| to_char(sysdate,'yyyy-mon-dd hh24:mi:ss'));

dbms_output.put_line('Inserted booking records:'|| v_bk_records_written||' out of '||v_rowtotal||' main cursor selected bookings');

dbms_output.put_line('No. bookings failed because no otop sale rec:'|| v_no_otop);

dbms_output.put_line('No. bookings zeroised because no accom_financial_detail:'|| v_count_noafd);

dbms_output.put_line('No. new booking_accom rows:'|| v_num_bkac_ins);

dbms_output.put_line('No. updated booking rows:'|| v_num_bk_upd);

dbms_output.put_line('No. updated booking_accom rows (at least) :'|| v_num_bkac_upd);

dbms_output.put_line('No. missing accruals set to zero:'||v_count_missing_accruals);

utl_file.put_line(v_file_handle,'[EOF]');

utl_file.fclose(v_file_handle) ;



utl_file.put_line(v_file_log,'[EOF]');

utl_file.fclose(v_file_log) ;





EXCEPTION

when others then

        dbms_output.put_line('Error in statement:'||v_statement);

        dbms_output.put_line('SQLCODE:'||sqlcode||' SQLERRM:'||sqlerrm);

        dbms_output.put_line('Booking ref:'||v_book_ref||'  Seas:'||v_season);





END; -- main pl/sql block

/


