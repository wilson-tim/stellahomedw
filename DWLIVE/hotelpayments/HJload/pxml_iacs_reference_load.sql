CREATE OR REPLACE Package pkg_xml_to_iacs_reference_load as
        procedure insert_into_error_table(filename varchar2,data_record varchar2,description1 varchar2,code varchar2,description2 varchar2);
        procedure location_load;
        procedure property_load;
        Procedure otop_property_load;
        Procedure clear_ref_temp_tables;

End pkg_xml_to_iacs_reference_load;
/
show err

-------------------------------------------------------------------------------------------------

CREATE OR REPLACE Package body pkg_xml_to_iacs_reference_load as

--Version 1.0   Initial Version - This Package loads data from xml data files (supplied by
--                                Hayes and Jarvis) into iacs reference tables(location,property,otop_property)

-- 1.1          JR             - Changes in the season type 'C' is replaced by 'S'(Summer) and 'D' by 'W'(Winter)

v_filename varchar2(30);
v_error_message1 varchar2(100);
v_error_message2 varchar2(100);
v_error_code     varchar2(20);
v_exist          Float ;

v_file_log              utl_file.file_type;
v_logging               boolean := TRUE;
v_statement             number;
v_data_record           varchar2(100);
li_updatecount          number;
v_severity              number;

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
-- parameter3 is not used

        Insert into iacs.iacs_general_error
        Values (v_datetime,filename,data_record,'',description1,code,description2,v_severity);

        Commit;

        Exception When others then
          dbms_output.put_line('Error occured while inserting into iacs.iacs.general table');
          dbms_output.put_line('Error code is :' || sqlcode ||' Error message is : ' || sqlerrm);
          v_mess1 := sqlerrm;
          v_code  := sqlcode;
          v_severity := 5;

--        Rollback;
          Insert into iacs.iacs_general_error
          Values (v_datetime,'PROGRAM GENERATED ERROR','WHILE INSERTING INTO IACS_GENERAL_ERROR TABLE','',v_mess1,v_code,'',v_severity);
 --         Commit;

End insert_into_error_table ;
-------------------------------------------------------------------------------------------------

Procedure location_load is

v_locationcount    number  := 0 ;
v_coc_count        number  := 0 ;


Cursor c_location is
        Select location_code,description, language_code, country_code, country_description
        From iacs.temp_xml_location ;


Begin

For c_location_row IN c_location Loop

Begin


        Update iacs.location
        Set   description               = c_location_row.description,
              language_code             = c_location_row.language_code,
              amended_date_time         = sysdate,
              amended_user_id           = user,
              amended_process           = 'XML LOAD',
              country_code              = c_location_row.country_code,
              country_description       = c_location_row.country_description,
              ccy_code                  = 'USD'   -- Hardcoded as not provided in the xml data file
        Where location_code             = c_location_row.location_code ;

           li_updatecount := SQL%ROWCOUNT ;

           If li_updatecount = 0 then

                        Insert into iacs.location
                        Values (c_location_row.location_code,
                        c_location_row.description,
                        c_location_row.language_code,
                        sysdate,                           -- amended_date_time
                        user,                              -- amended_user_id
                        'XML LOAD',                        -- amended_process
                        c_location_row.country_code,
                        c_location_row.country_description,
                        'USD');
           End if;
           v_locationcount := v_locationcount + 1;

-----------------------------
-- Add Country_office_correlation if there is a new country code else ignore it.
        select count(*)
        into v_coc_count
        from iacs.country_office_correlation
        where country_code = c_location_row.country_code ;

        If v_coc_count = 0 then
                Insert into country_office_correlation
                values ('CRA',c_location_row.country_code);
        End if ;

--------------------------------

        Exception
                When others then
                 dbms_output.put_line('Error at Location Code : ' || c_location_row.location_code || ' and Error Code is : ' || sqlcode);
                 dbms_output.put_line('Error Message : ' || sqlerrm);
                v_filename              := 'location.xml';
                v_data_record           := 'Location Code:' || c_location_row.location_code;
                v_error_code            := sqlcode;
                v_error_message1        := substr(sqlerrm,1,100);
                v_error_message2        := substr(sqlerrm,101,200);
                v_severity              := 5;
                insert_into_error_table(v_filename,v_data_record,v_error_message1,v_error_code,v_error_message2);

        End;
  End loop;

   Commit;

dbms_output.put_line(' NO. OF LOCATIONS SUCCESSFULLY LOADED : ' || v_locationcount);

 End location_load;

------------------------------------------------------------------------------------------------------

Procedure property_load is

--ls_prop_logfile varchar2(40) ;
v_propertycount  number  := 0 ;

Cursor c_property is
        Select property_num, substr(property_name,1,30) property_name,location_code, gateway_code
        from iacs.temp_xml_property ;

Begin
--lv_ref_filename := to_char(sysdate,'yyyymmdd') || 'property_debug.txt' ;

--commented for debug
--ls_prop_logfile := 'hj_property.txt';
-- v_file_log := utl_file.fopen('/data/hotelpayments/XMLFILES',ls_prop_logfile,'w') ;

v_statement := 181;
--f_log(null);

For c_property_row in c_property Loop

Begin

        --curnode := sys.xmldom.item(v_property,j-1);

v_statement := 217;
--f_log(null);

                Update iacs.property
                Set property_name     = c_property_row.property_name,
                    location_code     = c_property_row.location_code,
                    amended_date_time = sysdate,              -- amended_date_time
                    amended_user_id   = user,                 -- amended_user_id
                    amended_process   = 'XML LOAD',           -- amended_process,
                    aptos_n_code      = 'N-HandJ',            -- dummy N code created for Hayes and Jarvis , iacs maintance to map to the correct one
                    gateway_code      = c_property_row.gateway_code
                Where property_num     = c_property_row.property_num;

                      li_updatecount := SQL%ROWCOUNT ;


v_statement := 244;
--f_log(null);

   If li_updatecount = 0 then

        Insert into iacs.property
        Values (c_property_row.property_num,
                c_property_row.property_name,
                c_property_row.location_code,
                sysdate,
                user,
                'XML LOAD',
                'N-HandJ',
                c_property_row.gateway_code);

v_statement := 259;
--f_log(null);

     End if;
        v_propertycount  := v_propertycount + 1;

        Exception
                When others then
                dbms_output.put_line('Error at Property Number : ' || c_property_row.property_num || ' and Error Code is : ' || sqlcode);
                dbms_output.put_line('Error Message : ' || sqlerrm);
                v_filename              := 'property.xml';
                v_data_record           := 'Property Number:'|| c_property_row.property_num ;
                v_error_code            := sqlcode;
                v_error_message1        := substr(sqlerrm,1,100);
                v_error_message2        := substr(sqlerrm,101,200);
                v_severity              := 5;
--              Rollback;
                insert_into_error_table(v_filename,v_data_record,v_error_message1,v_error_code,v_error_message2);

   End;

   End Loop;

v_statement := 268;
--f_log(null);

   Commit;


dbms_output.put_line(' NO. OF PROPERTIES SUCCESSFULLY LOADED : ' || v_propertycount);

utl_file.fclose(v_file_log) ;

v_statement := 286;
--f_log(null);

End property_load;

--------------------------------------------------------------------------------------------------------
Procedure otop_property_load is

v_otoppropcount         number  := 0;

Cursor c_otop_property is
  Select property_code,decode(substr(rtrim(season),1,1),'C','S','D','W',substr(rtrim(season),1,1))|| substr(rtrim(season),2,3) season, property_num
       From iacs.temp_xml_otop_property;

Begin

For c_otop_property_row in c_otop_property Loop

Begin

        Update iacs.otop_property
        Set property_num      = c_otop_property_row.property_num
        Where otop_accom_code = c_otop_property_row.property_code and
              season          = c_otop_property_row.season;

          li_updatecount := SQL%ROWCOUNT ;

          If  li_updatecount  = 0 then
                Insert into iacs.otop_property
                Values (c_otop_property_row.property_code,
                        c_otop_property_row.season,
                        c_otop_property_row.property_num);
         End if;

          v_otoppropcount := v_otoppropcount + 1;

             Exception
                When others then
                dbms_output.put_line('Error at Property Code/Season : ' || c_otop_property_row.property_code ||'/'||c_otop_property_row.season || ' and Error Code is : ' || sqlcode);
                dbms_output.put_line('Error Message : ' || sqlerrm);
                v_filename              := 'propertycode.xml';
                v_data_record           := 'Property Code(Otop Accom Code)/Season : ' || c_otop_property_row.property_code ||'/'||c_otop_property_row.season;
                v_error_code            := sqlcode;
                v_error_message1        := substr(sqlerrm,1,100);
                v_error_message2        := substr(sqlerrm,101,200);
                v_severity              := 0;
--              Rollback;
                insert_into_error_table(v_filename,v_data_record,v_error_message1,v_error_code,v_error_message2);

End;

End Loop;

Commit;
dbms_output.put_line(' NO. OF OTOP PROPERTIES SUCCESSFULLY LOADED : ' || v_otoppropcount);

End otop_property_load;

-------------------------------------------------------------------------------------------------
Procedure clear_ref_temp_tables is
Begin
         delete from iacs.temp_xml_location;
         delete from iacs.temp_xml_property ;
         delete from iacs.temp_xml_otop_property ;
         commit;

End clear_ref_temp_tables ;
-------------------------------------------------------------------------------------------------

End pkg_xml_to_iacs_reference_load;

--------------------------------------------------------------------------------------------------------

/

show err        
