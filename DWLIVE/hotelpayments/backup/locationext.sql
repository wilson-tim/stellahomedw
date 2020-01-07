set serveroutput on size 1000000



-- 1.0 Leigh Ashton 2/12/99     live version 
-- extract merlin location details for iacs


declare
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
        v_loc_cd                char(4);
        v_currency_cd           dw.m_country.currency_Cd%TYPE;
        v_ins_cnt               number(10) :=0;
        v_upd_cnt               number(10) :=0;

cursor maincursor is 
        select ml.location_cd, substr(ml.location_desc,1,45) location_desc,
        c.country_cd country_Cd, c.country_desc, c.currency_cd
        from dw.m_location ml, dw.m_country c, dw.m_region mr
        where ml.region_cd = mr.region_cd
        and mr.country_cd = c.country_cd;


BEGIN

v_statement :=10;



FOR c1 IN maincursor LOOP
        v_loc_cd := c1.location_cd;
        v_rowtotal := v_rowtotal + 1;
        v_statement :=45;

        /* override default country ccy for certain values as determined by users */
        IF c1.country_cd ='CU' THEN  -- cuba
                v_currency_cd := 'GBP';
        ELSIF c1.country_cd = 'DO' THEN -- dominican republic
                v_currency_cd := 'USD';
        ELSE
                v_currency_cd := c1.currency_cd;
        END IF;

        begin

        INSERT INTO iacs.location
                (LOCATION_CODE                  , 
                 DESCRIPTION                    ,
                 LANGUAGE_CODE                  ,
                 AMENDED_DATE_TIME              ,
                 AMENDED_USER_ID                ,
                 AMENDED_PROCESS                ,
                 COUNTRY_CODE                   ,
                 COUNTRY_DESCRIPTION            ,
                 CCY_CODE                       )
                VALUES
                (c1.location_cd,
                c1.location_desc,
                'ENG', -- default to english
                sysdate,
                user,
                'dw extract',
                c1.country_cd,
                c1.country_desc,
                v_currency_cd);
                
        v_ins_cnt := v_ins_cnt + 1;

        EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE iacs.location
                        SET description = c1.location_desc,
                        /* don't update language code, this is done by users in reference app */
                        country_code = c1.country_cd,
                        country_description = c1.country_Desc,
                        ccy_code = v_currency_cd
                        WHERE location_code = c1.location_cd;
                        v_upd_cnt := v_upd_cnt + 1;
        END;





END LOOP; -- maincursor loop


v_statement :=130;
dbms_output.put_line('End of extract at:'|| to_char(sysdate,'yyyy-mon-dd hh24:mi:ss'));
dbms_output.put_line('Extracted records:'|| v_rowtotal||' selected rows');
dbms_output.put_line('Inserted records:'|| v_ins_cnt);
dbms_output.put_line('Updated records:'|| v_upd_cnt);

EXCEPTION
when others then
        dbms_output.put_line('Error in statement:'||v_statement||',prop:'||v_loc_cd);
        dbms_output.put_line('SQLCODE:'||sqlcode||' SQLERRM:'||sqlerrm);


END; -- main pl/sql block
/

exit;

