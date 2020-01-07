CREATE OR REPLACE PROCEDURE App_Stat_DMIS_Check (p_RunId     IN     application_log.run_id%TYPE,
                                                 p_LogMethod IN     VARCHAR2,
                                                 p_Status    IN OUT application_status.application_status_code%TYPE,
                                                 p_Message   IN OUT application_status.application_message%TYPE,
                                                 p_ErrorCode IN OUT VARCHAR2) IS 

  v_AppKey               application.application_key%TYPE := 'DMIS_PER';
  v_CurrentSeason        application_registry.parameter_value%TYPE;

    
  v_count                INTEGER(10);
  v_Runs                 INTEGER(10);
  v_Checks               INTEGER(10);  
  v_GreenCount           INTEGER(10);
  v_AmberCount           INTEGER(10);
  v_RedCount             INTEGER(10);
  v_AcceptedTime         INTEGER(10);
  v_WarningTime          INTEGER(10);
  
  Dmis_Exception         EXCEPTION;
  
  CURSOR Dmis_Runs (c_Season VARCHAR2) IS
  SELECT mh.*,
         trunc(24*(mh.end_date - mh.start_date) * 60 * 60) seconds_to_run
  FROM monitor_history mh
  WHERE mh.season_year = to_char(to_date(substr(c_Season,2,2),'rr'),'yyyy')
  AND   mh.season_type = UPPER(substr(c_Season,1,1))
  AND   trunc(mh.start_date) = trunc(SYSDATE)
  ORDER BY mh.start_date DESC;
  
  BEGIN
    
    p_ErrorCode := 0;
    p_Status    := NULL;
            
    BEGIN

      -- Now actually check the application
      v_CurrentSeason := App_Util.Get_Parameter_Value(v_AppKey,'CurrentSeason');
    
      IF v_CurrentSeason IS NULL THEN
        -- Can't get season from Application_Registry
        -- Report and do nothing else
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Unable to Find valid season in app registry table',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);      
        p_ErrorCode := 1;               
        
        RAISE Dmis_Exception;
      END IF;

      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Season being checked :'||v_CurrentSeason,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
    
      -- Check to see how many seasonal runs have finished today
      SELECT COUNT(*) 
      INTO v_count
      FROM monitor_history mh
      WHERE mh.season_year = to_char(to_date(substr(v_CurrentSeason,2,2),'rr'),'yyyy')
      AND   mh.season_type = UPPER(substr(v_CurrentSeason,1,1))
      AND   trunc(mh.start_date) = trunc(SYSDATE);
      
      -- Get number of runs to check
      v_Runs   := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'JobsToCheck'));    
      v_Checks := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'JobFailureLevel'));
      
      IF v_Runs IS NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Number of runs to check not set in Application_Registry (JobsToCheck)',
                                                  'ERROR',
                                                  'ERROR',
                                                   p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Dmis_Exception;
      END IF;
      IF v_Checks IS NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Failure not set in Application_Registry (JobFailureLevel)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Dmis_Exception;
      END IF;
      
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Number of runs to check : '||v_Runs,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
                       
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Failure level set to : '||v_Checks,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
      
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Number of Dmis Runs today : '||v_Count,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
                     
      IF v_count < v_Runs THEN
        -- Number of runs today is less than number needed to make check
        -- Report and do nothing else
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Number of runs today less than minimum needed - Nothing to check',
                                                  'WARNING',
                                                  'WARNING',
                                                  p_LogMethod);
        p_ErrorCode := 99;               
        RAISE Dmis_Exception;
      END IF;
        
      -- Reset Counters
      v_GreenCount := 0;
      v_AmberCount := 0;
      v_RedCount   := 0;
      v_Count      := 0;
      -- Get Time levels from Application_Registry
      v_AcceptedTime := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'AcceptedTime'));
      v_WarningTime  := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'WarningTime'));

      IF v_AcceptedTime IS NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Accepted Time level not set in Application_Registry (AcceptedTime)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Dmis_Exception;
      END IF;
      
      IF v_WarningTime IS NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Warning Time level not set in Application_Registry (WarningTime)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Dmis_Exception;
      END IF;
             
      FOR v_Dmis IN Dmis_Runs(v_CurrentSeason) LOOP
        
        -- In each iteration of cursor check whether total time is in green, amber or red status
        -- and increment counters accordingly
        -- NB A red count would also trigger an amber count
          
        IF v_Dmis.Seconds_To_Run < (v_AcceptedTime * 60) THEN
          -- Time taken is below accepted level
          v_GreenCount := v_GreenCount + 1;
          p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                    p_RunId,
                                                    'Dmis Run in acceptable time - incrementing Green Count',
                                                    'PROGRESS',
                                                    'INFO',
                                                    p_LogMethod);      
        ELSIF (v_Dmis.Seconds_To_Run > (v_AcceptedTime * 60) AND v_Dmis.Seconds_To_Run < (v_WarningTime * 60)) THEN
          -- Time taken is between accepted and warning
          v_AmberCount := v_AmberCount + 1;
          p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                    p_RunId,
                                                    'Dmis Run in between acceptable and warning time - incrementing Amber Count',
                                                    'PROGRESS',
                                                    'INFO',
                                                    p_LogMethod);      
        ELSE
          -- Time taken is above warning time
          v_AmberCount := v_AmberCount + 1;
          v_RedCount   := v_RedCount + 1;  
          p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                    p_RunId,
                                                    'Dmis Run in unacceptable time - incrementing Red Count',
                                                    'PROGRESS',
                                                    'INFO',
                                                    p_LogMethod);      
        END IF;
          
        -- Increment Number of times through loop
        v_count := v_count + 1;
          
        -- If Number of times through loop matches 
        IF v_count = v_Runs THEN
          EXIT;
        END IF;    
      END LOOP;
        
      -- Set App_Status according to results
      IF v_RedCount >= v_Checks THEN
        p_Status := 'RED';
        p_Message := v_Checks||' or more runs out of the last '||v_Runs||' have taken more than '||v_WarningTime||' minutes to run - Immediate action required';
                               
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  v_Checks||' or more runs out of the last '||v_Runs||' have taken more than '||v_WarningTime||' minutes to run - Immediate action required',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
                         
      ELSIF v_AmberCount >= v_Checks THEN
        p_Status  := 'AMBER';
        p_Message := v_Checks||' or more runs out of the last '||v_Runs||' have taken more than '||v_AcceptedTime||' minutes to run - Please investigate';
                               
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  v_Checks||' or more runs out of the last '||v_Runs||' have taken more than '||v_AcceptedTime||' minutes to run - Please investigate',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      ELSE        
        p_Status := 'GREEN';
        p_Message := 'System Normal';
        
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'System Normal',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      END IF; 
        
      EXCEPTION 
      WHEN Dmis_Exception THEN
        NULL;
      
      WHEN OTHERS THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Error Occurred during Dmis_Status_Check '||SQLCODE||' '||SQLERRM,
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;
    END;  

END App_Stat_DMIS_Check;
/
