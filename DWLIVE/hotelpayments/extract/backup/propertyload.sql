-- extract iacs property details to otop_property record type and to property rec
-- update rows if details have changed since last run

-- 0.5 Leigh Ashton 4/10/99     First version
-- 1.0 Leigh Ashton 1/12/99     Live version
-- 2.0 Leigh Ashton 1/12/99     Version for new accom_corr link with property_reference_no from accom_detail
-- 2.1 Leigh        15/2/00     Tune
-- 2.2 Leigh        15/3/00     Tune!
-- 2.3 Leigh        13/12/00    Untune. Remove hints
-- 2.4 Leigh        2/7/01      Add order by to otop_prop cursor  
-- 2.5  Leigh      22/2/02      Add in dummy properties i.e. < 0
-- 2.6 Paul Butler  21/11/05    Add company_code
-- 2.7 Leigh        19/12/05    tuned otop property cursor - removed season line
-- 2.8 Paul Butler  22/12/05    Added company_code to select from iacs.property under dup_val_on_index
set serveroutput on size 1000000


DECLARE
        v_logging               boolean := TRUE; -- do you want performance logging?
        v_statement             number :=1;
        v_property_Num          dw.m_supplier.supp_no%TYPE;
        v_bkac_records_written  number(9) := 0;
        v_bk_records_written    number(9) := 0;
        v_rowtotal              number(9) := 0;
        v_file_handle1          utl_file.file_type;
        v_file_handle2          utl_file.file_type;
        ls_otop_rec    varchar2(800); -- 800 should be more than enough
        ls_booking_rec          varchar2(800); -- 800 should be more than enough
        ls_prop_rec             varchar2(800); -- 800 should be more than enough
        ls_ref_filename1         varchar2(40);
        ls_ref_filename2         varchar2(40);
        v_otop_count            number(10);
        ls_ref_logfile          varchar2(40);
        v_property_name         iacs.property.property_name%TYPE;
        v_location_code         iacs.property.location_code%TYPE;
        v_prop_upd_cnt          number(10) :=0;
        v_secs                  number(30);
        v_file_log              utl_file.file_type;

CURSOR maincursor IS
        SELECT  supp_nm property_name,
                supp_no property_Num,
                mrg.location_cd location_code
        FROM dw.m_supplier m, dw.m_resort r, dw.m_resort_group mrg
        WHERE r.resort_cd = m.resort_cd
        and mrg.resort_group_cd = r.resort_group_cd
      UNION
        select p.property_name, p.property_reference_no, c.location_code from property p, contract c
        where 
        c.property_reference_no = p.property_reference_no
        and p.property_reference_no < 0
        and c.location_code is not null
        and c.location_code <> '????'
        and exists (select null from iacs.location il
                 where il.location_code = c.location_code)
                ;


-- for otop_prop cursor , may want to use this tuning?? /*+ ORDERED INDEX(a) INDEX(c) */
/* added order by to get most recent mapping last */
CURSOR otop_prop (in_prop_num number) IS
SELECT    c.season_type||substr(c.season_year,3,2) season,
        to_number(c.otop_accom_code) otop_accom_code, a.gateway_code gateway_code
        from  contract m, accom_correlation c, accom_gateway a
        WHERE c.contract_version = m.contract_version
        AND c.contract_reference_no = m.contract_reference_no
        -- removed LA 19/12/05 to speed up -- and (c.season_year > '1999' or (c.season_year = '1999' and c.season_type = 'W'))
        and m.property_reference_no = in_prop_num
        and a.season_year = c.season_year
        and a.season_type = c.season_type
        and a.otop_accom_code = c.otop_accom_code
        GROUP by c.season_type||substr(c.season_year,3,2) ,
        to_number(c.otop_accom_code), a.gateway_code
order by c.season_type||substr(c.season_year,3,2) desc  ;


PROCEDURE f_log (v_null varchar2) IS
        BEGIN

        IF v_logging THEN 
                SELECT hsecs into v_secs FROM v$timer;
                utl_file.put_line(v_file_log,'S:'||v_statement||' '||to_char(sysdate,'yy-mon-dd hh24:mi:ss')||' '||v_secs);
        END IF;
END f_log; -- end function

---------------------------------------------------------------------
BEGIN
---------------------------------------------------------------------


v_statement :=10;

ls_ref_logfile := '1proplog.txt';

--v_file_log := utl_file.fopen('/home/dw/DWLIVE/logs/hotelpayments',ls_ref_logfile,'w') ;
v_file_log := utl_file.fopen('/data/hotelpayments/export',ls_ref_logfile,'w') ;



f_log(null);


v_statement :=15;

f_log(null);

FOR c1 IN maincursor LOOP
        v_property_num := c1.property_num;
        v_rowtotal := v_rowtotal + 1;
        v_statement :=45;
        f_log(null);
        BEGIN

        INSERT INTO iacs.property
                (PROPERTY_NUM               ,
                 COMPANY_CODE               ,     -- 21/11/05
                 PROPERTY_NAME             ,
                 LOCATION_CODE             ,
                 AMENDED_DATE_TIME         ,
                 AMENDED_USER_ID           ,
                 AMENDED_PROCESS           ,
                 APTOS_N_CODE             
                 )
        VALUES
                (c1.property_num,
                'FCHF',          -- 21/11/05 mainstream 
                substr(c1.property_name,1,30),
                c1.location_code,
                sysdate,
                user,
                'dw extract ins',
                null
                );

        v_bkac_records_Written := v_bkac_records_written + 1;
        EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                        SELECT property_name, location_code
                        INTO v_property_name, v_location_code
                        FROM iacs.property
                        WHERE property_num = c1.property_num
                        and   company_code = 'FCHF';          -- 22/12/05 company_code now part of primary key
        
                        IF (v_property_name <> substr(c1.property_name,1,30)) OR
                          ( v_location_code <> c1.location_code) THEN
                        -- row has changed values, update row
                                UPDATE iacs.property
                                SET property_name = substr(c1.property_name,1,30),
                                location_code = c1.location_code,
                                amended_date_time = sysdate,
                                amended_user_id = user,
                                amended_process = 'dw extract upd'
                                WHERE property_Num = c1.property_num
                                AND company_code = 'FCHF';          -- 21/11/05 company_code now part of primary key

                                v_prop_upd_cnt := v_prop_upd_cnt + 1;
                        END IF;
        END;

        v_statement :=110;
        f_log(null);

        v_otop_count :=0;

        FOR o1 in otop_prop(v_property_num) LOOP
                v_statement :=113;
                f_log(null);
                v_otop_count := v_otop_count + 1;

                BEGIN

                        INSERT INTO iacs.otop_property
                                (otop_accom_code,
                                season,
                                property_num)
                        VALUES
                                (o1.otop_accom_code,
                                o1.season,
                                v_property_num);
                        EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                                UPDATE iacs.otop_property
                                SET property_num = v_property_Num
                                WHERE otop_Accom_code = o1.otop_Accom_code
                                AND season = o1.season;
                END;
                v_statement :=114;
                BEGIN
                        UPDATE iacs.property
                        SET gateway_code = o1.gateway_code
                        where property_Num = v_property_num
                        AND   company_code = 'FCHF';       -- 21/11/05  mainstream company_code
                        -- may do more than one row, but that's OK
                END;

                v_statement :=115;
                

        END LOOP; -- o1 loop

        v_statement :=118;
        f_log(null);
        IF v_otop_count = 0 THEN
                --dbms_output.put_line('No otop prop:'|| v_property_num);
                null;
        END IF;
        IF mod(v_rowtotal / 500,1) = 0 THEN 
                COMMIT;
        END IF;

        f_log(null);

END LOOP; -- maincursor loop


v_statement :=130;
f_log(null);

dbms_output.put_line('End of extract at:'|| to_char(sysdate,'yyyy-mon-dd hh24:mi:ss'));
dbms_output.put_line('Extracted records:'|| v_bkac_records_written||' out of '||v_rowtotal||' selected props');
dbms_output.put_line('Update property rows:'||v_prop_upd_cnt);

utl_file.put_line(v_file_log,'[EOF]');
utl_file.fclose(v_file_log) ;


EXCEPTION
when others then
        dbms_output.put_line('Error in statement:'||v_statement||',prop:'||v_property_num);
        dbms_output.put_line('SQLCODE:'||sqlcode||' SQLERRM:'||sqlerrm);


END; -- main pl/sql block
/
COMMIT;


EXIT;



