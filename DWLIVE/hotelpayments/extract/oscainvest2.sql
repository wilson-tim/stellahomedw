-- output osca file for use in mgt information of iacs
-- to be input into osca for comparison to speake accruals
set serveroutput on size 1000000



declare

        v_datecutoffstart DATE := '30-SEP-2000'; -- GREATER THAN THIS DATE
        v_datecutoffend DATE := '1-NOV-2000'; -- LESS THAN THIS DATE
        v_recs_written NUMBER :=0;
        v_ex_rate NUMBER(13,4);
        v_payment_uk_amt NUMBER(19,2);
        v_file_handle           utl_file.file_type;
        v_file_log              utl_file.file_type;
        v_data_rec    varchar2(800); -- 800 should be more than enough
        v_season_year char(4);

CURSOR maincur IS
SELECT b.booking_seq_num, substr(b.season,1,1) season_type, substr(b.season,2,2) season_year,
        lpad(to_char(b.booking_ref),8,0) booking_Ref, bai.booking_accom_invoice_seq_num,
        bai.payment_amt, ba.accrual_ccy_code, aptos_Extracted_date
FROM booking b, booking_accom ba, booking_Accom_invoice bai
WHERE b.booking_seq_num = ba.booking_seq_num
AND   ba.booking_seq_num = bai.booking_seq_num
AND   ba.booking_accom_seq_num = bai.booking_accom_seq_num
AND   bai.aptos_extracted_date > v_datecutoffstart
AND  bai.aptos_extracted_date < v_datecutoffend
and b.season = 'W99' and ba.accrual_ccy_code = 'USD'
ORDER by b.booking_ref
;



BEGIN  -- main section

dbms_output.put_line('started at:'||to_char(sysdate,'yyyy-mon-dd hh24:mi'));
dbms_output.put_line('cut off start date was :'||to_char(v_datecutoffstart,'yyyy-mon-dd'));
dbms_output.put_line('cut off end date was :'||to_char(v_datecutoffend,'yyyy-mon-dd'));
v_file_handle := utl_file.fopen('/data/hotelpayments/export','iacsdata.txt','w') ;

FOR cloop IN maincur LOOP

        IF cloop.season_year > 50 THEN 
                v_season_year :=  to_number(19||cloop.season_year);
        ELSE 
                v_season_year :=  to_number(20||cloop.season_year);
        END IF;

        begin
        SELECT uk_exchange_rate INTO v_ex_rate
        FROM currency_rate c
        WHERE c.season_type = cloop.season_type
        AND c.season_year = v_season_year
        AND c.currency_code  = cloop.accrual_ccy_code;
        
          exception
                when no_data_found THEN
                        dbms_output.put_line('nodatafound:'||cloop.booking_ref||cloop.accrual_ccy_code||
                           ' :'||cloop.booking_seq_num||':'||cloop.payment_amt);
                        v_ex_rate :=1;
      end;
        
        v_payment_uk_amt := round((cloop.payment_amt / v_ex_rate),2);
        
        v_data_rec := (cloop.season_type||','||
                        v_season_year||','||
                        cloop.booking_ref||','||
                        cloop.booking_accom_invoice_seq_num||','||
                        cloop.accrual_ccy_code||','||
                        v_payment_uk_amt
                        );

        utl_file.put_line(v_file_handle,v_data_rec);
        v_recs_written := v_recs_written + 1;
END LOOP;

utl_file.put_line(v_file_handle,'[EOF]');
utl_file.fclose(v_file_handle) ;

dbms_output.put_line ('records written:'|| v_recs_written);
dbms_output.put_line('ended at:'||to_char(sysdate,'yyyy-mon-dd hh24:mi'));
END;
/

exit;








