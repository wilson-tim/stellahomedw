-- extract iacs property details to otop_property record type and to property rec
-- update rows if details have changed since last run

-- 0.5 Leigh Ashton 4/10/99     First version
-- 1.0 Leigh Ashton 1/12/99     Live version

set serveroutput on size 1000000

-- create temporary index to help tuning/performance until have better otop/merlin correlation
connect dataw/dwhouse

CREATE index temp_cac_index on c_accom_correlation
(season_type, season_year, contract_Reference_no, contract_version)
tablespace TS_NS_D1_1;

-- attempt again in case that tablespace was full
CREATE index temp_cac_index on c_accom_correlation
(season_type, season_year, contract_Reference_no, contract_version)
tablespace Ts_user;
connect dw/dbp


DECLARE
        v_logging               boolean := FALSE; -- do you want performance logging?
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

cursor maincursor is 
        SELECT /*+ RULE*/ supp_nm property_name,
                supp_no property_Num,
                mrg.location_cd location_code
        FROM dw.m_supplier m, dw.m_resort r, dw.m_resort_Group mrg
        WHERE r.resort_cd = m.resort_cd
        and mrg.resort_group_cd = r.resort_group_cd;

cursor otop_prop (in_prop_num number) is
SELECT /*+ ORDERED INDEX(a,acgtw_pk) */ c.season_type||substr(c.season_year,3,2) season,
        to_number(c.otop_accom_code) otop_accom_code, a.gateway_code gateway_code
        from  dw.m_accom_contract m, c_accom_correlation c, accom_gateway a
        WHERE c.contract_version = m.contract_version
        AND c.contract_reference_no = m.contract_ref
        and c.season_year = '1999'
        and c.season_type = 'W'
        and m.supp_no = in_prop_num
        and a.season_year = c.season_year
        and a.season_type = c.season_type
        and a.otop_accom_code = c.otop_accom_code
        group by c.season_type||substr(c.season_year,3,2) ,
        to_number(c.otop_accom_code), a.gateway_code ;


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

ls_ref_logfile := 'proplog.txt';

v_file_log := utl_file.fopen('/data/hotelpayments/export/log',ls_ref_logfile,'w') ;



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
                 PROPERTY_NAME             ,
                 LOCATION_CODE             ,
                 AMENDED_DATE_TIME         ,
                 AMENDED_USER_ID           ,
                 AMENDED_PROCESS           ,
                 APTOS_N_CODE             
                 )
        VALUES
                (c1.property_num,
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
                        WHERE property_num = c1.property_num;
        
                        IF (v_property_name <> substr(c1.property_name,1,30)) OR
                          ( v_location_code <> c1.location_code) THEN
                        -- row has changed values, update row
                                UPDATE iacs.property
                                SET property_name = substr(c1.property_name,1,30),
                                location_code = c1.location_code,
                                amended_date_time = sysdate,
                                amended_user_id = user,
                                amended_process = 'dw extract upd'
                                WHERE property_Num = c1.property_num;

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
                        where property_Num = v_property_Num;
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
dbms_output.put_line('Extracted records:'|| v_bkac_records_written||' out of '||v_rowtotal||' selected bookings');
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


connect dataw/dwhouse

DROP INDEX temp_cac_index;

connect dw/dbp

EXIT;



