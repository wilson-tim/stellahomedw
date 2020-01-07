CREATE OR REPLACE PACKAGE APP_UTIL IS

  -- Author  : RBRYER
  -- Created : 26-Nov-02 13:03:42
  -- Purpose : General application utilities inc. Logging, Registery
  PROCEDURE log      (p_app_key CHAR,
                      p_run_id  IN OUT CHAR ,
                      p_log_seq IN OUT NUMBER ,
                      p_event_period CHAR,
                      p_event_type   CHAR,
                      p_event_level  CHAR,
                      p_event_summary CHAR,
                      p_event_detail  CHAR
                      );


 END APP_UTIL;
/
CREATE OR REPLACE PACKAGE BODY APP_UTIL IS

  PROCEDURE log      (p_app_key CHAR,
                      p_run_id  IN OUT CHAR,
                      p_log_seq IN OUT NUMBER ,
                      p_event_period CHAR,
                      p_event_type   CHAR,
                      p_event_level  CHAR,
                      p_event_summary CHAR,
                      p_event_detail  CHAR
                      )
  IS
  BEGIN

         INSERT
         INTO application_log
              (application_key,
               run_id,
               log_sequence,
               event_date,
               event_period,
               event_type,
               event_level,
               event_summary,
               event_detail
               )
          VALUES
               (substr(p_app_key,1,8)       ,
                substr(p_run_id,1,30)      ,
                p_log_seq       ,
                SYSDATE         ,
                substr(p_event_period,1,10)  ,
                substr(p_event_type,1,10)    ,
                substr(p_event_level,1,15)   ,
                substr(p_event_summary,1,50) ,
                substr(p_event_detail,1,200)
                );

           -- increment log sequence
           p_log_seq := p_log_seq + 1;

           COMMIT;
           
  EXCEPTION
           WHEN OTHERS THEN
                -- do nothing if there is an error
                -- we can't trap errors in the error logging
                -- function!!!
                NULL;
  END log;


END APP_UTIL;
/
