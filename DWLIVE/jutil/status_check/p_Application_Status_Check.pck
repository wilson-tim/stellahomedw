CREATE OR REPLACE PACKAGE p_Application_Status_Check IS

  -- Author  : JDURNFORD
  -- Created : 07/12/2005 09:37:52
  -- Purpose : Check the status of the warehouse by processing applications

  
  -- Procedure to allow an Insert from outside Oracle (i.e. from within a Unix Shell Script) that
  -- doesn't return any values.
  PROCEDURE Insert_App_Status_Unix (p_AppKey       IN     application_status.application_key%TYPE, 
                                    p_AppStatus    IN     application_status.application_status_code%TYPE,
                                    p_AppMessage   IN     application_status.application_message%TYPE);
  
  
  
  -- Procedure to Insert/Update an entry in the application_status table.  A trigger on the table
  -- will create an identical entry in the application_status_history table
  PROCEDURE Insert_App_Status (p_AppKey       IN     application_status.application_key%TYPE, 
                               p_AppStatus    IN     application_status.application_status_code%TYPE,
                               p_AppMessage   IN     application_status.application_message%TYPE,
                               p_ErrorCode    IN OUT INTEGER,
                               p_ErrorMessage IN OUT VARCHAR2);

                               

  -- Procedure to Create Entries in whatever logging method is used for the checks
  PROCEDURE App_Status_Log (p_AppKey    IN   application_log.application_key%TYPE,
                            p_RunId     IN   application_log.run_id%TYPE,
                            p_Message   IN   application_status.application_message%TYPE,
                            p_Type      IN   application_log.event_type%TYPE,
                            p_Level     IN   application_log.event_level%TYPE,
                            p_LogMethod IN   application_registry.parameter_value%TYPE);
  
  
                            
  -- ***********************************************************************************************
  -- *  Because of the Dynamic Nature of this application, the only way to get the processes to    *
  -- *  work was to call a function which returns and success/failure value back to the main       *
  -- *  calling procedure (Check_Application_Status).  The only thing that these functions do is   *
  -- *  call the true check procedure (which are stored in package P_APP_STAT_PROCEDURES).         *
  -- *  These procedures have IN OUT parameters which are then stored as global variables so they  *
  -- *  can be used by Check_Application_Status to log the status of the relevant application.     *
  -- *  For some reason they don't work when they are not public ?????                             *
  -- ***********************************************************************************************

  -- Function to check the status of dmis runs
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION Dmis_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                              p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;

  
  
  -- Function to check the status of synergex load
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION Synergex_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                                  p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;

  
  
  -- Function to check the status of redo
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION Redo1_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                               p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;

  
  
  -- Function to check the status of fin calcs
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION FinCalc_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                                 p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;
  
  
  
  -- Function to check the status of xmis monitor table
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION Xmis_Monitor_Check (p_RunId     IN  application_log.run_id%TYPE,
                               p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;

  
  
  -- Function to check the status of xmis overall
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION Xmis_Overall_Check (p_RunId     IN  application_log.run_id%TYPE,
                               p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;
  
  
  
  -- Function to check the status of TCat Load
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION Tcat_Load_Check (p_RunId     IN  application_log.run_id%TYPE,
                            p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;
  

  
  -- Function to check the status of Retail Profit
  -- Return value can be  0 - Success
  --                      1 - Failure
  --                     99 - Successful completion with warnings
  FUNCTION Retail_Profit_Load_Check (p_RunId     IN  application_log.run_id%TYPE,
                                     p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;


  FUNCTION Retail_FX_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                                   p_LogMethod IN VARCHAR2) 
  RETURN INTEGER;
  
  -- Main Application Status Check Procedure.  Calling this procedure will envoke the
  -- correct checking procedures to be run (as long as they are set up correctly in
  -- the application registry) 
  -- The procedure also needs to be within this package and must be made a public procedure
  PROCEDURE Check_Application_Status (p_AppKey   IN   application.application_key%TYPE);
  
END p_Application_Status_Check;
/
CREATE OR REPLACE PACKAGE BODY p_Application_Status_Check IS

  -- Global variables to be used by dynamically called functions to be
  -- able to pass back final results of check into Check_Application_Status
  g_Status       application_status.application_status_code%TYPE;
  g_Message      application_status.application_message%TYPE; 

-- **************************************************************
-- *  Insert_App_Status (from Unix)                             *
-- **************************************************************

  PROCEDURE Insert_App_Status_Unix (p_AppKey       IN     application_status.application_key%TYPE, 
                                    p_AppStatus    IN     application_status.application_status_code%TYPE,
                                    p_AppMessage   IN     application_status.application_message%TYPE) IS

    v_Code     INTEGER(10);
    v_Message  VARCHAR2(1000);
    
  BEGIN
  
    Insert_App_Status(p_AppKey,
                      p_AppStatus,
                      p_AppMessage,
                      v_Code,
                      v_Message);
                      
  END Insert_App_Status_Unix;                                    
  
  
  
-- **************************************************************
-- *  Insert_App_Status                                         *
-- **************************************************************

  PROCEDURE Insert_App_Status (p_AppKey       IN     application_status.application_key%TYPE, 
                               p_AppStatus    IN     application_status.application_status_code%TYPE,
                               p_AppMessage   IN     application_status.application_message%TYPE,
                               p_ErrorCode    IN OUT INTEGER,
                               p_ErrorMessage IN OUT VARCHAR2) IS
  
  v_count              INTEGER;
  
  BEGIN
  
    p_ErrorCode := 0;
    p_ErrorMessage := NULL;
    
    -- Check to see if Application is valid
    SELECT COUNT(*)
    INTO v_count
    FROM application app
    WHERE app.application_key = p_AppKey;
    
    IF v_count = 0 THEN
        -- Application not valid, pass error message back to calling procedure
        p_ErrorCode    := 1;
        p_ErrorMessage := 'Application Passed ('||p_AppKey||') does not exist in Application Table';      
    ELSE     
      -- Check to see if Application Status Code is valid
      SELECT COUNT(*) 
      INTO v_count
      FROM status_level sl
      WHERE sl.application_status_code = p_AppStatus;
     
      IF v_count = 0 THEN
        -- Application Status Code not valid, pass error message back to calling procedure
        p_ErrorCode    := 1;
        p_ErrorMessage := 'Status Level Passed ('||p_AppStatus||') does not exist in Status Level Table';      
      ELSE  
        BEGIN
          MERGE INTO application_status app
          USING (SELECT p_AppKey      application_key,
                        p_AppStatus   application_status_code,
                        p_AppMessage  application_message
                 FROM dual) d
          ON (d.application_key          = app.application_key)
          WHEN MATCHED THEN
            UPDATE
              SET app.last_checked_at_datetime = SYSDATE,
                  app.application_status_code  = d.application_status_code,
                  app.application_message      = d.application_message
          WHEN NOT MATCHED THEN
            INSERT
              (app.application_key,
               app.last_checked_at_datetime,
               app.application_status_code,
               app.application_message)
              VALUES
              (d.application_key,
               SYSDATE,
               d.application_status_code,
               d.application_message);
          
          COMMIT;         
           
          EXCEPTION
          WHEN OTHERS THEN
            p_ErrorCode    := 1;
            p_ErrorMessage := 'Oracle Error '||SQLCODE||' occurred :- '||SQLERRM;
             
        END;  
         
      END IF;
    END IF;  
  END Insert_App_Status;
  

  
-- **************************************************************
-- *  App_Status_Log                                            *
-- **************************************************************

  PROCEDURE App_Status_Log (p_AppKey    IN   application_log.application_key%TYPE,
                            p_RunId     IN   application_log.run_id%TYPE,
                            p_Message   IN   application_status.application_message%TYPE,
                            p_Type      IN   application_log.event_type%TYPE,
                            p_Level     IN   application_log.event_level%TYPE,
                            p_LogMethod IN   application_registry.parameter_value%TYPE) IS

  v_output_file           utl_file.file_type;
  v_filename              VARCHAR2(25);
  v_path                  application_registry.parameter_value%TYPE;
  v_lognum                application_log.log_sequence%TYPE;
  
  BEGIN
  
  
    IF p_LogMethod = 'F' THEN -- File
      
      BEGIN
        -- Get values for v_path from application registry
        v_path := App_Util.Get_Parameter_Value(p_AppKey,'UTLFILEDIR');
        IF v_path IS NULL THEN
          v_path := '/home/dw/SQL_Output';          
        END IF;
          
        -- Make filename from App_Key & RunId
        v_filename := p_AppKey||'_'||Substr(p_RunId,1,8)||'.txt';
      
        -- Opening in Append mode will create file if it doesn't already exist
        v_output_file := utl_file.fopen(v_path, v_filename, 'A');        
        utl_file.put_line(v_output_file,p_Level||' - '||p_Message);
        utl_file.fflush(v_output_file);
        utl_file.fclose(v_output_file);
        
        EXCEPTION
        -- Handle an errors created by use of utl_file
        WHEN UTL_FILE.INVALID_PATH THEN
          v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
          app_util.log(p_Appkey,
                       p_RunId,
                       v_lognum,
                       'ALL',
                       'ERROR',
                       'ERROR',
                       'Error caused due to invalid path spefication',
                       'Error caused due to invalid path spefication'); 
        WHEN UTL_FILE.INVALID_MODE THEN
          v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
          app_util.log(p_Appkey,
                       p_RunId,
                       v_lognum,
                       'ALL',
                       'ERROR',
                       'ERROR',
                       'Error caused due to invalid mode',
                       'Error caused due to invalid mode'); 
        WHEN UTL_FILE.INVALID_FILEHANDLE THEN
          v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
          app_util.log(p_Appkey,
                       p_RunId,
                       v_lognum,
                       'ALL',
                       'ERROR',
                       'ERROR',
                       'Error caused due to invalid file handle',
                       'Error caused due to invalid path handle'); 
        WHEN UTL_FILE.INVALID_OPERATION THEN
          v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
          app_util.log(p_Appkey,
                       p_RunId,
                       v_lognum,
                       'ALL',
                       'ERROR',
                       'ERROR',
                       'Error caused due to invalid operation',
                       'Error caused due to invalid operation'); 
        WHEN UTL_FILE.READ_ERROR THEN
          v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
          app_util.log(p_Appkey,
                       p_RunId,
                       v_lognum,
                       'ALL',
                       'ERROR',
                       'ERROR',
                       'Error caused due to read error',
                       'Error caused due to read error'); 
        WHEN UTL_FILE.WRITE_ERROR THEN
          v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
          app_util.log(p_Appkey,
                       p_RunId,
                       v_lognum,
                       'ALL',
                       'ERROR',
                       'ERROR',
                       'Error caused due to write error',
                       'Error caused due to write error'); 
        WHEN OTHERS THEN
          v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
          app_util.log(p_Appkey,
                       p_RunId,
                       v_lognum,
                       'ALL',
                       'ERROR',
                       'ERROR',
                       'Error caused due to '||SQLCODE,
                       SQLERRM);     
      END;
      
    ELSIF p_LogMethod = 'D' THEN -- Database
      v_lognum := App_Util.Next_Log_Number(p_Appkey,p_RunId);
      app_util.log(p_Appkey,
                   p_RunId,
                   v_lognum,
                   'ALL',
                   p_Type,
                   p_Level,
                   Substr(p_Message,1,50),
                   Substr(p_Message,1,200)); 
    END IF;
    
  END App_Status_Log;


  
-- **************************************************************
-- *  Dmis Checking Procedure                                   *
-- **************************************************************
    
  FUNCTION Dmis_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                              p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_Dmis_Check(p_Runid,
                                              p_LogMethod,
                                              v_Status,
                                              v_Message,
                                              v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END Dmis_Status_Check;

  
  
-- **************************************************************
-- *  Synergex Checking Procedure                               *
-- **************************************************************
    
  FUNCTION Synergex_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                                  p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_Synergex_Check(p_Runid,
                                                  p_LogMethod,
                                                  v_Status,
                                                  v_Message,
                                                  v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END Synergex_Status_Check;
  
  
  
-- **************************************************************
-- *  Redo Checking Procedure                                   *
-- **************************************************************
    
  FUNCTION Redo1_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                               p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_Redo1_Check(p_Runid,
                                               p_LogMethod,
                                               v_Status,
                                               v_Message,
                                               v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END Redo1_Status_Check;
 
 
  
-- **************************************************************
-- *  Fin Calc Status Check                                     *
-- **************************************************************
    
  FUNCTION FinCalc_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                                 p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_FinCalc_Check(p_Runid,
                                                 p_LogMethod,
                                                 v_Status,
                                                 v_Message,
                                                 v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END FinCalc_Status_Check;
  
  
  
-- **************************************************************
-- *  Xmis Monitor Check                                        *
-- **************************************************************
    
  FUNCTION Xmis_Monitor_Check (p_RunId     IN  application_log.run_id%TYPE,
                               p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_Xmis_Check(p_Runid,
                                              p_LogMethod,
                                              v_Status,
                                              v_Message,
                                              v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END Xmis_Monitor_Check;
  
  
  
-- **************************************************************
-- *  Xmis Overall Check                                        *
-- **************************************************************
    
  FUNCTION Xmis_Overall_Check (p_RunId     IN  application_log.run_id%TYPE,
                               p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_Xmis_Overall(p_Runid,
                                                p_LogMethod,
                                                v_Status,
                                                v_Message,
                                                v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END Xmis_Overall_Check;
  
  
  
-- **************************************************************
-- *  TCat Load Check                                           *
-- **************************************************************
    
  FUNCTION Tcat_Load_Check (p_RunId     IN  application_log.run_id%TYPE,
                            p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_TCat_Load(p_Runid,
                                             p_LogMethod,
                                             v_Status,
                                             v_Message,
                                             v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END TCat_Load_Check;


  
-- **************************************************************
-- *  Retail Profit Check                                       *
-- **************************************************************
    
  FUNCTION Retail_Profit_Load_Check (p_RunId     IN  application_log.run_id%TYPE,
                                     p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_Retail_Profit(p_Runid,
                                                 p_LogMethod,
                                                 v_Status,
                                                 v_Message,
                                                 v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END Retail_Profit_Load_Check;



-- **************************************************************
-- *  Retail FX Check                                           *
-- **************************************************************
    
  FUNCTION Retail_FX_Status_Check (p_RunId     IN  application_log.run_id%TYPE,
                                   p_LogMethod IN VARCHAR2) 
  RETURN INTEGER IS
  
  v_status          application_status.application_status_code%TYPE;
  v_message         application_status.application_message%TYPE;
  v_ErrorCode       VARCHAR2(100);
    
  BEGIN
    
    p_App_Stat_Procedures.App_Stat_Retail_FX(p_Runid,
                                             p_LogMethod,
                                             v_Status,
                                             v_Message,
                                             v_ErrorCode);
        
    g_Status  := v_Status;
    g_Message := v_Message;
    
    RETURN(v_ErrorCode);
    
  END Retail_FX_Status_Check;


  
-- **************************************************************
-- *  Main Application Status Procedure                         *
-- **************************************************************

  PROCEDURE Check_Application_Status (p_AppKey     IN   application.application_key%TYPE) IS

  v_function           application_registry.parameter_value%TYPE;
  v_Subject            application_registry.parameter_value%TYPE;
  v_AutoPage           application_registry.parameter_value%TYPE;
  v_RunId              application_log.run_id%TYPE;
  v_LogNum             application_log.log_sequence%TYPE;
  v_Disabled           application.status_check_disabled_ind%TYPE;
  v_StatusDescription  status_level.application_status_desc%TYPE;
  v_database           v$database.NAME%TYPE;
      
  v_sql                VARCHAR2(1000);
  v_LogMethod          VARCHAR2(1);
  v_ErrorCode          VARCHAR2(100) := 0;
  v_ErrorMessage       VARCHAR2(255);
  
  v_Code               INTEGER(10);  
  v_HoldFor            INTEGER(10);
  
  Deletion_Error       EXCEPTION;
  App_Not_Set          EXCEPTION;
  
  BEGIN
  
    SELECT NAME 
    INTO v_database
    FROM v$database;
    
    -- Check to see if status check for application has been disabled
    BEGIN
      SELECT status_check_disabled_ind
      INTO v_Disabled
      FROM application
      WHERE application_key = p_AppKey;
      
      EXCEPTION
      WHEN no_data_found THEN
        App_Status_Log('APP_STAT',
                       v_RunId,
                       'Application '||p_AppKey||' not set up in Application Table',
                       'WARNING',
                       'WARNING',
                       v_LogMethod); 
        
        p_Email_Role.Email_Role(p_AppKey,
                                v_database||' - '||'Application '||p_AppKey||' has not been set up in Application Tables Correctly',
                                v_database||' - '||'Application '||p_AppKey||' has not been set up in Application Tables Correctly');
                               
        v_Disabled := 'Y';
        RAISE App_Not_Set;
        
    END;
    
    v_LogMethod := To_Char(Substr(App_Util.Get_Parameter_Value(p_AppKey,'LogMethod'),1,1));
    
    IF v_LogMethod IS NULL THEN  
      v_LogMethod := 'F'; -- Default to Log File
    END IF;

    p_common.Debug_Message('Output Mode set to : '||v_LogMethod);
    
    -- Create RunId for Application (in case using Application_Log Table)
    v_RunId := App_Util.Create_Run_Id;
    p_Common.Debug_Message('Run Id set to : '||v_RunId);      
    
    -- Store Start time of Application in Application Log - Regardless of how logging is done
    App_Util.Store_Start_Time(p_AppKey,
                              v_RunId);
                                
    -- Store Start time in Text file if appropriate logging method used
    IF v_LogMethod = 'F' THEN
      App_Status_Log(p_AppKey,
                     v_RunId,
                     'Start Time of Run '||to_char(SYSDATE,'dd/mm/yyyy HH24:MI:SS'),
                     '',
                     '',
                     v_LogMethod);                       
        
    END IF;                                
        
    IF v_Disabled != 'Y' THEN  
      v_function := App_Util.Get_Parameter_Value('APP_STAT',p_AppKey);
      IF v_function IS NOT NULL THEN

        BEGIN
          v_sql := 'Begin '||
                   '  :v_retval := p_Application_Status_Check.'||v_function||'('''||v_runId||''','''||v_LogMethod||''');'||
                   'End;';  
          dbms_output.put_line(v_sql);
                  
          EXECUTE IMMEDIATE (v_sql) USING OUT v_Code;
        
          -- Insert into Application_Status Table using Global Variables Set
          -- as long as checking procedures have not returned a null value
          IF g_Status IS NOT NULL THEN
            Insert_App_Status (p_AppKey,
                               g_Status,
                               g_Message,
                               v_ErrorCode,
                               v_ErrorMessage);
          
            -- Check that setting of table has worked and log if failure occured
            IF v_ErrorCode = 1 THEN
              App_Status_Log(p_AppKey,
                             v_RunId,
                             'Error Occurred during setting of App_Status '||v_ErrorMessage,
                             'ERROR',
                             'ERROR',
                             v_LogMethod);
            END IF;
          END IF;
                  
          -- Now check return code from function
          IF v_Code = 0 THEN
            App_Status_Log(p_AppKey,
                           v_RunId,
                           'Successful Status Check',
                           'PROGRESS',
                           'INFO',
                           v_LogMethod); 
                         
            -- Send Email Based on Returned value
            BEGIN
              SELECT sl.application_status_desc
              INTO v_StatusDescription
              FROM status_level sl
              WHERE sl.application_status_code = g_Status;
                
              EXCEPTION
              WHEN no_data_found THEN
                v_StatusDescription := NULL;
            END;
            
            IF g_status != 'GREY' THEN
              v_Subject := v_database||' - '||p_AppKey||' : Status '||g_status||' '||v_StatusDescription;
              p_Email_Role.Email_Role(p_AppKey||'_'||g_Status,
                                      v_Subject,
                                      g_Message);
            END IF;
            
            -- Check to see if application needs an AutoPage message
            IF g_Status = 'RED' THEN
              v_AutoPage := App_Util.Get_Parameter_Value(p_AppKey,'AutoPageRed');
            ELSIF g_status = 'AMBER' THEN
              v_AutoPage := App_Util.Get_Parameter_Value(p_AppKey,'AutoPageAmber');
            ELSIF g_status = 'GREEN' THEN  
              v_AutoPage := App_Util.Get_Parameter_Value(p_AppKey,'AutoPageGreen');
            END IF;  

            IF v_AutoPage IS NOT NULL THEN
              
              App_Status_Log(p_AppKey,
                             v_RunId,
                             'Sending Text message',
                             'PROGRESS',
                             'INFO',
                             v_LogMethod);
                           
              App_Util.send_email('smtp',
                                  p_AppKey,
                                  v_AutoPage,
                                  v_Subject,
                                  g_Message);
                
            END IF;
            
          ELSIF v_Code = 1 THEN
            App_Status_Log(p_AppKey,
                           v_RunId,
                           'Function '||v_Function||' has returned an error code - Please investigate',
                           'WARNING',
                           'WARNING',
                           v_LogMethod);
            p_Email_Role.Email_Role(p_AppKey,
                                    v_database||' - '||'Error Occurred during run of '||p_AppKey||' - Function '||v_Function||' has returned error code - Please investigate',
                                    v_database||' - '||'Error Occurred during run of '||p_AppKey||' - Function '||v_Function||' has returned error code - Please investigate');
          ELSIF v_Code = 99 THEN 
            p_Email_Role.Email_Role(p_AppKey,
                                    v_database||' - '||'Successful completion of '||p_AppKey||' checks with warnings - Check Log File',
                                    v_database||' - '||'Successful completion of '||p_AppKey||' checks with warnings - Check Log File');
          
          END IF;

          EXCEPTION
          WHEN OTHERS THEN
            App_Status_Log(p_AppKey,
                           v_RunId,
                           'Error '||SQLCODE||' occurred when trying to run '||TRIM(v_function)||' '||SQLERRM,
                           'WARNING',
                           'WARNING',
                           v_LogMethod);                       
            p_Email_Role.Email_Role(p_AppKey,
                                    v_database||' - '||'Error has occurred trying to run '||p_AppKey||' - Function '||v_function,
                                    v_database||' - '||'Error '||SQLCODE||' occurred when trying to run '||TRIM(v_function)||' '||SQLERRM);
        END;  
      
        -- Remove any old logs in application log table and records from application_status_history table
        BEGIN
          v_HoldFor := To_Number(App_Util.Get_Parameter_Value(p_AppKey,'HoldLogsFor'));
          IF v_HoldFor IS NULL THEN
            App_Status_Log(p_AppKey,
                           v_RunId,
                           'Period to hold logs for not set in Application_Registry (HoldLogsFor)',
                           'WARNING',
                           'WARNING',
                           v_LogMethod);
            
                           
            p_Email_Role.Email_Role(p_AppKey,
                                    v_database||' - '||'Period to hold logs for not set in Application_Registry (HoldLogsFor)',
                                    v_database||' - '||'Period to hold logs for not set in Application_Registry (HoldLogsFor)');
                            
            RAISE Deletion_Error;
          END IF;

          v_sql := 'Delete from application_log al '||
                   'where al.application_key = '''||p_AppKey||''' '||
                   'and trunc(al.event_date) < trunc(sysdate) - '||v_HoldFor;
               
          EXECUTE IMMEDIATE (v_sql);         

          COMMIT;
          App_Status_Log(p_AppKey,
                         v_RunId,
                         'Deleted Logs more than '||v_HoldFor||' days old',
                         'PROGRESS',
                         'INFO',
                         v_LogMethod);                       
            
          -- now delete old entries from appliaction_status_history table
          v_sql := 'Delete from application_status_history ash '||
                   'where ash.application_key = '''||p_AppKey||''' '||
                   'and trunc(ash.checked_at_datetime) < trunc(sysdate) - '||v_HoldFor;
               
          EXECUTE IMMEDIATE (v_sql);         

          COMMIT;
          App_Status_Log(p_AppKey,
                         v_RunId,
                         'Deleted History records more than '||v_HoldFor||' days old',
                         'PROGRESS',
                         'INFO',
                         v_LogMethod);                       
            

          EXCEPTION
          WHEN Deletion_Error THEN
            NULL;
        
          WHEN OTHERS THEN
            App_Status_Log(p_AppKey,
                           v_RunId,
                           'Error occurred when trying to delete old records '||SQLCODE||' '||SQLERRM,
                           'WARNING',
                           'WARNING',
                           v_LogMethod);                       
        END;
    
    
        -- Store Start time of Application in Application Log - Regardless of how logging is done
        App_Util.Store_End_Time(p_AppKey,
                                v_RunId);
                                
        -- Store End time in Text file if appropriate logging method used
        IF v_LogMethod = 'F' THEN
          App_Status_Log(p_AppKey,
                         v_RunId,
                         'End Time of Run '||to_char(SYSDATE,'dd/mm/yyyy HH24:MI:SS'),
                         '',
                         '',
                         v_LogMethod);                       
        
          App_Status_Log(p_AppKey,
                         v_RunId,
                         '',
                         '',
                         '',
                         v_LogMethod);                       
        END IF;                                
      
      ELSE
        v_lognum := App_Util.Next_Log_Number('APP_STAT',v_RunId);
        app_util.log('APP_STAT',
                     v_RunId,
                     v_lognum,
                     'ALL',
                     'WARNING',
                     'WARNING',
                     'Unable to Find Required Function',
                     'Error occurred when trying to find Function '||v_function||' for '||p_AppKey);
                   
        p_Email_Role.Email_Role('APP_STAT',
                                v_database||' - '||'Application '||p_AppKey||' has not been set up in Application Tables Correctly',
                                v_database||' - '||'Application '||p_AppKey||' has not been set up in Application Tables Correctly');
                                           
      END IF;  
    ELSE  
      Insert_App_Status (p_AppKey,
                         'GREY',
                         'Status Check Disabled',
                         v_ErrorCode,
                         v_ErrorMessage);
                               
      App_Status_Log(p_AppKey,
                     v_RunId,
                     'Status Check Disabled',
                     'PROGRESS',
                     'INFO',
                     v_LogMethod);      

      -- Store Start time of Application in Application Log - Regardless of how logging is done
      App_Util.Store_End_Time(p_AppKey,
                              v_RunId);
                                
      -- Store End time in Text file if appropriate logging method used
      IF v_LogMethod = 'F' THEN
        App_Status_Log(p_AppKey,
                       v_RunId,
                       'End Time of Run '||to_char(SYSDATE,'dd/mm/yyyy HH24:MI:SS'),
                       '',
                       '',
                       v_LogMethod);                       
        
        App_Status_Log(p_AppKey,
                       v_RunId,
                       '',
                       '',
                       '',
                       v_LogMethod);                       
      END IF;                                
    END IF;  
    
    EXCEPTION
    WHEN App_Not_Set THEN
      NULL;
      
  END Check_Application_Status; 
  
   
BEGIN 
  -- Initialization
  NULL;
END p_Application_Status_Check;
/
