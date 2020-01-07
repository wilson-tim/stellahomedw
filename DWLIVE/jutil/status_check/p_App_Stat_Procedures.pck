CREATE OR REPLACE PACKAGE p_App_Stat_Procedures IS

  -- Author  : JDURNFORD
  -- Created : 22/02/2006 13:35:49
  -- Purpose : Contain the separate procedures called from p_Application_Status_Check

PROCEDURE App_Stat_DMIS_Check (p_RunId     IN     application_log.run_id%TYPE,
                               p_LogMethod IN     VARCHAR2,
                               p_Status    IN OUT application_status.application_status_code%TYPE,
                               p_Message   IN OUT application_status.application_message%TYPE,
                               p_ErrorCode IN OUT VARCHAR2);
  
  
  
PROCEDURE App_Stat_Synergex_Check (p_RunId     IN     application_log.run_id%TYPE,
                                   p_LogMethod IN     VARCHAR2,
                                   p_Status    IN OUT application_status.application_status_code%TYPE,
                                   p_Message   IN OUT application_status.application_message%TYPE,
                                   p_ErrorCode IN OUT VARCHAR2);

                                   
                                   
PROCEDURE App_Stat_FinCalc_Check (p_RunId     IN     application_log.run_id%TYPE,
                                  p_LogMethod IN     VARCHAR2,
                                  p_Status    IN OUT application_status.application_status_code%TYPE,
                                  p_Message   IN OUT application_status.application_message%TYPE,
                                  p_ErrorCode IN OUT VARCHAR2);

                                  
                                  
PROCEDURE App_Stat_Redo1_Check (p_RunId     IN     application_log.run_id%TYPE,
                                p_LogMethod IN     VARCHAR2,
                                p_Status    IN OUT application_status.application_status_code%TYPE,
                                p_Message   IN OUT application_status.application_message%TYPE,
                                p_ErrorCode IN OUT VARCHAR2);
  
  
  
PROCEDURE App_Stat_Xmis_Check (p_RunId     IN     application_log.run_id%TYPE,
                               p_LogMethod IN     VARCHAR2,
                               p_Status    IN OUT application_status.application_status_code%TYPE,
                               p_Message   IN OUT application_status.application_message%TYPE,
                               p_ErrorCode IN OUT VARCHAR2);
  
  
  
PROCEDURE App_Stat_Xmis_Overall (p_RunId     IN     application_log.run_id%TYPE,
                                 p_LogMethod IN     VARCHAR2,
                                 p_Status    IN OUT application_status.application_status_code%TYPE,
                                 p_Message   IN OUT application_status.application_message%TYPE,
                                 p_ErrorCode IN OUT VARCHAR2);

                                 
                                 
PROCEDURE App_Stat_TCat_Load (p_RunId     IN     application_log.run_id%TYPE,
                              p_LogMethod IN     VARCHAR2,
                              p_Status    IN OUT application_status.application_status_code%TYPE,
                              p_Message   IN OUT application_status.application_message%TYPE,
                              p_ErrorCode IN OUT VARCHAR2);

                              
                              
PROCEDURE App_Stat_Retail_Profit (p_RunId     IN     application_log.run_id%TYPE,
                                  p_LogMethod IN     VARCHAR2,
                                  p_Status    IN OUT application_status.application_status_code%TYPE,
                                  p_Message   IN OUT application_status.application_message%TYPE,
                                  p_ErrorCode IN OUT VARCHAR2);


                              
PROCEDURE App_Stat_Retail_FX (p_RunId     IN     application_log.run_id%TYPE,
                              p_LogMethod IN     VARCHAR2,
                              p_Status    IN OUT application_status.application_status_code%TYPE,
                              p_Message   IN OUT application_status.application_message%TYPE,
                              p_ErrorCode IN OUT VARCHAR2);



PROCEDURE App_Stat_TccLoad (p_RunId     IN     application_log.run_id%TYPE,
                            p_LogMethod IN     VARCHAR2,
                            p_Status    IN OUT application_status.application_status_code%TYPE,
                            p_Message   IN OUT application_status.application_message%TYPE,
                            p_ErrorCode IN OUT VARCHAR2);


PROCEDURE App_Stat_FXOrder (p_RunId     IN     application_log.run_id%TYPE,
                            p_LogMethod IN     VARCHAR2,
                            p_Status    IN OUT application_status.application_status_code%TYPE,
                            p_Message   IN OUT application_status.application_message%TYPE,
                            p_ErrorCode IN OUT VARCHAR2);

PROCEDURE Set_Dmis_Season;

END p_App_Stat_Procedures;
/
CREATE OR REPLACE PACKAGE BODY p_App_Stat_Procedures IS

-- ********************************************************************************
-- * DMIS Checking Routine                                                        *
-- ********************************************************************************

PROCEDURE App_Stat_DMIS_Check (p_RunId     IN     application_log.run_id%TYPE,
                               p_LogMethod IN     VARCHAR2,
                               p_Status    IN OUT application_status.application_status_code%TYPE,
                               p_Message   IN OUT application_status.application_message%TYPE,
                               p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks that the last few (number set in application_registry)
  -- DMIS runs has finished in what is considered an acceptable time frame
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   21/02/2006   Original Version                             *
  * John Durnford   11/09/2006   Changed to look at bookings per minute as    *
  *                              opposed to just overall time                 *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare Variables
  v_AppKey               application.application_key%TYPE := 'DMIS_PER';
  v_CurrentSeason        application_registry.parameter_value%TYPE;

    
  v_count                INTEGER(10);
  v_Runs                 INTEGER(10);
  v_Checks               INTEGER(10);  
  v_GreenCount           INTEGER(10);
  v_AmberCount           INTEGER(10);
  v_RedCount             INTEGER(10);
  v_AcceptedBookings     NUMBER(10,2);
  v_WarningBookings      NUMBER(10,2);
  
  Dmis_Exception         EXCEPTION;
  
  CURSOR Dmis_Runs (c_Season VARCHAR2) IS
  SELECT mh.*
  FROM monitor_history mh
  WHERE mh.season_year = to_char(to_date(substr(c_Season,2,2),'rr'),'yyyy')
  AND   mh.season_type = UPPER(substr(c_Season,1,1))
  AND   trunc(mh.start_date) = trunc(SYSDATE)
  AND   mh.end_date IS NOT NULL
  AND   mh.CONTEXT = 'DMIS'
  AND   mh.app_stat_code != 'GREY'
  AND   mh.app_stat_code IS NOT NULL
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
      v_AcceptedBookings := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'AcceptedBookings'));
      v_WarningBookings  := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'WarningBookings'));

      IF v_AcceptedBookings IS NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Accepted Bookings not set in Application_Registry (AcceptedTime)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Dmis_Exception;
      END IF;
      
      IF v_WarningBookings IS NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Warning Bookings not set in Application_Registry (WarningTime)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Dmis_Exception;
      END IF;
             
      FOR v_Dmis IN Dmis_Runs(v_CurrentSeason) LOOP
        
        -- In each iteration of cursor check whether status is green, amber or red status
        -- as listed in the monitor_history table and increment counters accordingly
        -- NB A red count would also trigger an amber count
        
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Bookings per Minute : '||v_Dmis.Bookings_Per_Min,
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);

        IF v_Dmis.App_Stat_Code = 'GREEN' THEN
          -- Everything OK
          v_GreenCount := v_GreenCount + 1;
          p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                    p_RunId,
                                                    'Dmis Run in acceptable time - incrementing Green Count',
                                                    'PROGRESS',
                                                    'INFO',
                                                    p_LogMethod);      
        ELSIF v_Dmis.App_Stat_Code = 'AMBER' THEN
            -- Time taken is between accepted and warning
            v_AmberCount := v_AmberCount + 1;
            p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                      p_RunId,
                                                      'Dmis Run in between acceptable and warning time - incrementing Amber Count',
                                                      'PROGRESS',
                                                      'INFO',
                                                      p_LogMethod);      
        ELSIF v_Dmis.App_Stat_Code = 'RED' THEN
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
        p_Message := v_Checks||' or more runs out of the last '||v_Runs||' have loaded less than '||v_WarningBookings||' bookings per minute - Immediate action required';
                               
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  v_Checks||' or more runs out of the last '||v_Runs||' have loaded less than '||v_WarningBookings||' bookings per minute - Immediate action required',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
                         
      ELSIF v_AmberCount >= v_Checks THEN
        p_Status  := 'AMBER';
        p_Message := v_Checks||' or more runs out of the last '||v_Runs||' have loaded less than '||v_AcceptedBookings||' bookings per minute - Please investigate';
                               
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  v_Checks||' or more runs out of the last '||v_Runs||' have loaded less than '||v_AcceptedBookings||' bookings per minute - Please investigate',
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



-- ********************************************************************************
-- * Synergex Checking Routine                                                    *
-- ********************************************************************************

PROCEDURE App_Stat_Synergex_Check (p_RunId     IN     application_log.run_id%TYPE,
                                   p_LogMethod IN     VARCHAR2,
                                   p_Status    IN OUT application_status.application_status_code%TYPE,
                                   p_Message   IN OUT application_status.application_message%TYPE,
                                   p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks that the number of bookings loaded into dwrtc.booking_master
  -- is above a set number in the last few minutes (numbers set in application_registry)
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   21/02/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare Variables
  v_AppKey               application.application_key%TYPE := 'SYNERGEX';

  v_NumMinutes           INTEGER(10);
  v_AcceptedBkgs         INTEGER(10);
  v_WarningBkgs          INTEGER(10);
  v_count                INTEGER(10);
    
  Synergex_Exception         EXCEPTION;
  
  
  BEGIN
    
    -- Set return parameters to default success
    p_ErrorCode := 0;
    p_Status    := NULL;
            
    BEGIN

      -- Get number of minutes to check load over
      v_NumMinutes := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'NumMinutes'));
      IF v_NumMinutes IS NULL THEN
        -- Couldn't find value in application_registry
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Number of minutes not set in Application_Registry (NumMinutes)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Synergex_Exception;
      END IF;
      
      -- Log values
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Number of minutes to check over : '||v_NumMinutes,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
                       
        
      -- Get Booking levels from Application_Registry
      v_AcceptedBkgs := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'AcceptedBookings'));
      v_WarningBkgs  := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'WarningBookings'));

      IF v_AcceptedBkgs IS NULL THEN
        -- Couldn't find value in application_registry
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Accepted Booking level not set in Application_Registry (AcceptedBookings)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Synergex_Exception;
      END IF;
      
      IF v_WarningBkgs IS NULL THEN
        -- Couldn't find value in application_registry
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Warning Booking level not set in Application_Registry (WarningBookings)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Synergex_Exception;
      END IF;

      -- Main Check
      -- Check how many bookings have been "loaded" in the last few minutes
      -- (Actual number of minutes retrieved from application_registry)
      SELECT
      COUNT(*)
      INTO v_count
      FROM dwrtc.booking_master bm
      WHERE bm.fch_load_timestamp >= SYSDATE - (1 / (24 * 60 / v_NumMinutes));
      
      -- Set status according to results
      IF v_count >= v_AcceptedBkgs THEN
        p_Status := 'GREEN';
        p_Message := 'System Normal';
        
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'System Normal - '||v_count||' bookings loaded in '||v_NumMinutes||' minutes',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      ELSIF (v_count < v_AcceptedBkgs AND v_count > v_WarningBkgs) THEN
        p_Status := 'AMBER';
        p_Message := 'Synergex Load is slow '||v_count||' Bookings loaded in '||v_NumMinutes||' minutes';
        
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'AMBER - '||v_count||' bookings loaded in '||v_NumMinutes||' minutes',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      ELSE 
        p_Status := 'RED';
        p_Message := 'Synergex Load is critically slow '||v_count||' Bookings loaded in '||v_NumMinutes||' minutes';
        
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'RED - '||v_count||' bookings loaded in '||v_NumMinutes||' minutes',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      END IF;
      
        
      EXCEPTION 
      WHEN Synergex_Exception THEN
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

END App_Stat_Synergex_Check;


-- ********************************************************************************
-- * FinCalc Checking Routine                                                     *
-- ********************************************************************************

PROCEDURE App_Stat_FinCalc_Check (p_RunId     IN     application_log.run_id%TYPE,
                                  p_LogMethod IN     VARCHAR2,
                                  p_Status    IN OUT application_status.application_status_code%TYPE,
                                  p_Message   IN OUT application_status.application_message%TYPE,
                                  p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks for the completion of fin calcs (generally occurring
  -- after tour ops integration) an accepted tolerance level has been included
  -- The seasons being checked are based on the main_current_season flag in the
  -- season table
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   21/02/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare relevant variables
  v_AppKey               application.application_key%TYPE := 'FIN_CALC';
 
  v_FailedSeasons        VARCHAR2(30) := NULL;

  v_AcceptedAmt          NUMBER(10) := 0;
  v_Remaining            NUMBER(10) := 0;
    
  v_FinCalcFailure       BOOLEAN := FALSE;

  -- Season Cursor Loop
  CURSOR Cur_Seasons IS
  SELECT   ssn.season_type,
           ssn.season_year
  FROM     season ssn         
  WHERE    ssn.main_current_season = 'Y'
  ORDER BY ssn.season_year,
           ssn.season_type;
  
  BEGIN
    
    -- Set Returning paramters as success
    p_ErrorCode := 0;
    p_Status    := NULL;

    v_AcceptedAmt := App_Util.Get_Parameter_Value(v_AppKey,'AcceptedAmt');
    
    IF v_AcceptedAmt IS NULL THEN
      -- Can't get season from Application_Registry
      -- Report but use default value of 1000
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Unable to Find valid season in app registry table',
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);      
      v_AcceptedAmt := 1000;
    END IF;
    
    -- Loop through all valid seasons
    FOR v_seasons IN Cur_Seasons LOOP
      -- Log current season being checked
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Checking Season : '||v_seasons.season_type||v_seasons.season_year,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
                                                  

      -- Attempt to get end time of last nights redo run
      -- Based on last fin calc run of the day
      SELECT COUNT(*) 
      INTO   v_Remaining
      FROM   dataw.fin_calc_control fcc
      WHERE  fcc.season_year  = v_seasons.season_year
      AND    fcc.season_type  = v_seasons.season_type
      AND    fcc.dmis_flag   != 'Y'
      AND    fcc.booking_processed != 'Y';
        

      -- If Number remaining > accepted level then flag as error
      IF v_Remaining > v_AcceptedAmt THEN
        v_FinCalcFailure := TRUE;
        v_FailedSeasons := v_FailedSeasons||v_seasons.season_type||v_seasons.season_year||' ';
      END IF;
                                                          
    END LOOP;
      
    -- NB. No Amber status either success or failure
    IF v_FinCalcFailure = FALSE THEN
      -- Set return values
      p_Status := 'GREEN';
      p_Message := 'System Normal - All Seasons Finished';
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'System Normal -  - All Seasons Finished',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    ELSE
      -- Set return values
      p_Status := 'AMBER';
      p_Message := 'FinCalcs still running - '||v_FailedSeasons;
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'AMBER - '||v_FailedSeasons,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    END IF;                       
        
    -- Catch an exceptions that may have occurred
    EXCEPTION 
    WHEN OTHERS THEN
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Error Occurred during App_Stat_FinCalc_Check '||SQLCODE||' '||SQLERRM,
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);
      p_ErrorCode := 1;

END App_Stat_FinCalc_Check;



-- ********************************************************************************
-- * Redo Checking Routine                                                        *
-- ********************************************************************************

PROCEDURE App_Stat_Redo1_Check (p_RunId     IN     application_log.run_id%TYPE,
                                p_LogMethod IN     VARCHAR2,
                                p_Status    IN OUT application_status.application_status_code%TYPE,
                                p_Message   IN OUT application_status.application_message%TYPE,
                                p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks for the completion of last nights redo1 fin calcs
  -- The seasons being checked are based on the main_current_season flag in the
  -- season table
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   21/02/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare relevant variables
  v_AppKey               application.application_key%TYPE := 'REDO_1';
  v_End_DateTime         dw.fin_calc_times.end_datetime%TYPE;

  v_FailedSeasons        VARCHAR2(30) := NULL;
  
  v_RedoFailure          BOOLEAN := FALSE;
      
  -- Season Cursor Loop
  CURSOR Cur_Seasons IS
  SELECT   ssn.season_type,
           ssn.season_year
  FROM     season ssn         
  WHERE    ssn.main_current_season = 'Y'
  ORDER BY ssn.season_year,
           ssn.season_type;
  
  BEGIN
    
    -- Set Returning paramters as success
    p_ErrorCode := 0;
    p_Status    := NULL;
    
    BEGIN

      -- Loop through all valid seasons
      FOR v_seasons IN Cur_Seasons LOOP
        -- Log current season being checked
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Checking Season : '||v_seasons.season_type||v_seasons.season_year,
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);
                                                  

        -- Attempt to get end time of last nights redo run
        -- Based on last fin calc run of the day
        BEGIN
          SELECT fct.end_datetime 
          INTO   v_End_DateTime
          FROM   dw.fin_calc_times fct
          WHERE  fct.season_year    = v_seasons.season_year
          AND    fct.season_type    = v_seasons.season_type
          AND    fct.start_datetime = (SELECT MAX(fct2.start_datetime)
                                       FROM   dw.fin_calc_times fct2
                                       WHERE  fct2.season_year           = fct.season_year
                                       AND    fct2.season_type           = fct.season_type
                                       AND    trunc(fct2.start_datetime) = trunc(SYSDATE) - 1
                                       );
          EXCEPTION
          WHEN no_data_found THEN
            v_end_datetime := NULL;
        END;                                       

        -- If no date found then assume redo1 failed to finish
        IF v_End_DateTime IS NULL THEN
          v_RedoFailure := TRUE;
          v_FailedSeasons := v_FailedSeasons||v_seasons.season_type||v_seasons.season_year||' ';
        END IF;
                                                          
      END LOOP;
      
      -- NB. No Amber status either success or failure
      IF v_RedoFailure = FALSE THEN
        -- Set return values
        p_Status := 'GREEN';
        p_Message := 'System Normal - All Seasons Finished';
        
        -- and log message
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'System Normal -  - All Seasons Finished',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      ELSE
        -- Set return values
        p_Status := 'AMBER';
        p_Message := 'Redo1 Failed - '||v_FailedSeasons;
        
        -- and log message
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'AMBER - '||v_FailedSeasons,
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      END IF;                       
        
      -- Catch an exceptions that may have occurred
      EXCEPTION 
      WHEN OTHERS THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Error Occurred during App_Stat_Redo1_Check '||SQLCODE||' '||SQLERRM,
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;
    END;  

END App_Stat_Redo1_Check;



-- ********************************************************************************
-- * Xmis Monitor Checking Routine                                                *
-- ********************************************************************************

PROCEDURE App_Stat_Xmis_Check (p_RunId     IN     application_log.run_id%TYPE,
                               p_LogMethod IN     VARCHAR2,
                               p_Status    IN OUT application_status.application_status_code%TYPE,
                               p_Message   IN OUT application_status.application_message%TYPE,
                               p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks for the completion of xmis (tourops integration) 
  -- by checking the monitor table set when each season completes
  -- The seasons being checked are based on the main_current_season flag in the
  -- season table
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   21/02/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare relevant variables
  v_AppKey               application.application_key%TYPE := 'XMIS_MON';
  v_status               dw.monitor.status%TYPE;
  
  v_FailedSeasons        VARCHAR2(30) := NULL;

  v_XmisFailure           BOOLEAN := FALSE;

  -- Season Cursor Loop
  CURSOR Cur_Seasons IS
  SELECT   ssn.season_type,
           ssn.season_year
  FROM     season ssn         
  WHERE    ssn.main_current_season = 'Y'
  ORDER BY ssn.season_year,
           ssn.season_type;
  
  BEGIN
    
    -- Set Returning paramters as success
    p_ErrorCode := 0;
    p_Status    := NULL;

    -- Loop through all valid seasons
    FOR v_seasons IN Cur_Seasons LOOP
      -- Log current season being checked
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Checking Season : '||v_seasons.season_type||v_seasons.season_year,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
                                                  

      -- Attempt to get end time of last nights redo run
      -- Based on last fin calc run of the day
      BEGIN
        SELECT m.status
        INTO   v_status
        FROM   monitor m
        WHERE  m.season_year = v_seasons.season_year
        AND    m.season_type = v_seasons.season_type
        AND    m.context     = 'XMIS';        
        
        EXCEPTION
        WHEN no_data_found THEN
          v_status := 'NOT STARTED';
      END;
      
      -- If Number remaining > accepted level then flag as error
      IF v_status != 'COMPLETED' THEN
        v_XmisFailure := TRUE;
        v_FailedSeasons := v_FailedSeasons||v_seasons.season_type||v_seasons.season_year||' ';
      END IF;
                                                          
    END LOOP;
      
    -- NB. No Amber status either success or failure
    IF v_XmisFailure = FALSE THEN
      -- Set return values
      p_Status := 'GREEN';
      p_Message := 'System Normal - All Seasons Finished';
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'System Normal -  - All Seasons Finished',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    ELSE
      -- Set return values
      p_Status := 'RED';
      p_Message := 'Xmis still running - '||v_FailedSeasons;
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'RED - '||v_FailedSeasons,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    END IF;                       
        
    -- Catch an exceptions that may have occurred
    EXCEPTION 
    WHEN OTHERS THEN
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Error Occurred during App_Stat_Xmis_Check '||SQLCODE||' '||SQLERRM,
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);
      p_ErrorCode := 1;

END App_Stat_Xmis_Check;



-- ********************************************************************************
-- * Xmis Overall Checking Routine                                                *
-- ********************************************************************************

PROCEDURE App_Stat_Xmis_Overall (p_RunId     IN     application_log.run_id%TYPE,
                                 p_LogMethod IN     VARCHAR2,
                                 p_Status    IN OUT application_status.application_status_code%TYPE,
                                 p_Message   IN OUT application_status.application_message%TYPE,
                                 p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks for the application status of the five applications
  -- associated with the full successfull completion of tour ops integration 
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   21/02/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare relevant variables
  v_AppKey                application.application_key%TYPE := 'XMISOVER';
  v_CheckList             application_registry.parameter_value%TYPE;
  v_OverallCheck          application_status.application_status_code%TYPE;
  v_FinalStatus           application_status.application_status_code%TYPE := 'GREEN';
  
  v_FailedApps            VARCHAR2(1000);
  
  Xmis_Exception          EXCEPTION;

  -- Private Function within procedure to return value of application status
  -- for selected application key
  FUNCTION Get_AppStat_Status(p_AppKey  IN  application_status.application_key%TYPE) 
  RETURN application_status.application_status_code%TYPE IS 
    v_Result    application_status.application_status_code%TYPE;
    
  BEGIN 
    BEGIN 
      SELECT app.application_status_code
      INTO v_Result
      FROM application_status app
      WHERE app.application_key = p_AppKey;
      
      EXCEPTION
      WHEN no_data_found THEN
        v_Result := 'RED';
    END;
    
    RETURN(v_Result);
  END Get_AppStat_Status;  


  BEGIN
    
    -- Set Returning paramters as success
    p_ErrorCode := 0;
    p_Status    := NULL;

    -- Get Name of file containing list of market files
    v_CheckList := App_Util.Get_Parameter_Value(v_AppKey,'CheckList');    
    IF v_CheckList IS NULL THEN
      -- Can't get name of Check List file from Application_Registry
      -- Set as RED and investigate manually
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Unable to Find CheckList file in app registry table',
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);      
      p_ErrorCode := 1;               
        
      RAISE Xmis_Exception;
    END IF;
    
    FOR v_Apps IN (SELECT apps.list_element app_key
                   FROM TABLE(p_common.Get_Separated_List(v_CheckList)) apps) LOOP
                   
      v_OverallCheck := Get_AppStat_Status(v_apps.app_key);
      
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Checking Success of App : '||v_apps.app_key||' Status - '||v_OverallCheck,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);
      
      
      IF v_OverallCheck != 'GREEN' THEN
        -- Store App Key of failed application
        v_FailedApps := v_FailedApps||v_apps.app_key||' ';
        
        -- Set overall status of XMISOVER application
        IF v_OverallCheck = 'AMBER' THEN
          -- Don't set to a lower status if a RED application has already
          -- been found
          IF v_FinalStatus != 'RED' THEN
            -- Store Amber status
            v_FinalStatus := 'AMBER';
          END IF;
        ELSIF v_OverallCheck = 'RED' THEN
          -- Store Red status
          v_FinalStatus := 'RED';  
        END IF;
      END IF;  
    END LOOP;
                   
    p_Status := v_FinalStatus;
    IF v_FinalStatus = 'GREEN' THEN
      -- Set return values
      p_Message := 'System Normal - Overall XMIS Succeeded';
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'System Normal - Overall XMIS Succeeded',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    ELSIF v_FinalStatus = 'AMBER' THEN
      -- Set return values
      p_Message := 'Overall Xmis Failed - Fincalcs Issue only '||v_FailedApps;
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'AMBER - Overall Xmis Failed - Fincalcs Issue Only',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      

      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Failed Apps '||v_FailedApps,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    ELSE
      -- Set return values
      p_Message := 'Overall Xmis Failed due to failures in following areas - '||v_FailedApps;
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'RED - Overall Xmis Failed ',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      

      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Failed Apps '||v_FailedApps,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    END IF;                       
        
    -- Catch an exceptions that may have occurred
    EXCEPTION 
    WHEN Xmis_Exception THEN
      p_Status := 'RED';
      
    WHEN OTHERS THEN
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Error Occurred during App_Stat_Xmis_Check '||SQLCODE||' '||SQLERRM,
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);
      p_ErrorCode := 1;

END App_Stat_Xmis_Overall;



-- ********************************************************************************
-- * TravelCat Load Checking Routine                                              *
-- ********************************************************************************

PROCEDURE App_Stat_TCat_Load (p_RunId     IN     application_log.run_id%TYPE,
                              p_LogMethod IN     VARCHAR2,
                              p_Status    IN OUT application_status.application_status_code%TYPE,
                              p_Message   IN OUT application_status.application_message%TYPE,
                              p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks for the application status of TravelCat Integration
  -- It performs three simple checks to ascertain a successfull load
  -- 1. - Run has started
  -- 2. - Run has finished successfully or is still running
  -- 3. - If run has finished then count number of transactions loaded is greater than minimum level
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   02/03/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare relevant variables
  v_AppKey                application.application_key%TYPE := 'TCATLOAD';
  v_CompanyList           application_registry.parameter_value%TYPE;
  v_MinTransList          application_registry.parameter_value%TYPE;  
  v_FinalStatus           application_status.application_status_code%TYPE := 'GREEN';
  v_LoadRun               dwr.wh_load_run.load_run_id%TYPE;
  v_Status                dwr.wh_load_run.status%TYPE;
  v_FullCompany           dwr.wh_load_run.owner_name%TYPE;
  v_CompanyStatus         application_status.application_status_code%TYPE;
  v_Count                 INTEGER(10);

  v_FailedCompanies       VARCHAR2(100) := NULL;
  v_TransCompanies        VARCHAR2(100) := NULL;
        
  TCat_Exception          EXCEPTION;


  -- Cursor to retrieve list of companies to check and the minimum number of
  -- transactions expected
  CURSOR Cur_Tcat_Companies (c_CompanyList   IN  application_registry.parameter_value%TYPE,
                             c_MinTransList  IN  application_registry.parameter_value%TYPE) IS
  SELECT Companies.list_element comp_key,
         MinTrans.list_element min_trans
  FROM TABLE(p_common.Get_Separated_List(c_CompanyList)) Companies,
       TABLE(p_common.Get_Separated_List(c_MinTransList)) MinTrans
  WHERE Companies.list_element_position = MinTrans.list_element_position;
  
  BEGIN
    
    -- Set Returning paramters as success
    p_ErrorCode := 0;
    p_Status    := NULL;

    -- Get List of Companies and Minimum Transactions expected
    -- NB. The CSV Listing of the above data must in the same order for this to work
    v_CompanyList  := App_Util.Get_Parameter_Value(v_AppKey,'CompanyList');    
    v_MinTransList := App_Util.Get_Parameter_Value(v_AppKey,'MinTransList');
    
    IF v_CompanyList IS NULL THEN
      -- Can't get name of Check List file from Application_Registry
      -- Set as RED and investigate manually
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Unable to Find CompanyList file in app registry table',
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);      
      p_ErrorCode := 1;               
        
      RAISE TCat_Exception;
    END IF;
    
    IF v_MinTransList IS NULL THEN
      -- Can't get name of Check List file from Application_Registry
      -- Set as RED and investigate manually
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Unable to Find MinTransList file in app registry table',
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);      
      p_ErrorCode := 1;               
        
      RAISE TCat_Exception;
    END IF;
    
    FOR v_Companies IN Cur_Tcat_Companies (v_CompanyList,
                                           v_MinTransList) LOOP

      -- Set Company Status to Green to start with
      v_CompanyStatus := 'GREEN';                                           
      
      -- Log which company being checked
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Checking Company '||v_Companies.Comp_Key,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);

      -- Create full company code
      v_FullCompany := 'DWR'||v_Companies.Comp_Key;
                                                      
      -- Check run for this company has started today
      BEGIN
        SELECT whlr.load_run_id,
               whlr.status        
        INTO   v_LoadRun,
               v_Status
        FROM   wh_load_run whlr
        WHERE  whlr.owner_name = v_FullCompany
        AND    trunc(whlr.run_start_datetime) = trunc(SYSDATE)
        AND    whlr.load_run_id = (SELECT MAX(whlr2.load_run_id)
                                   FROM   wh_load_run whlr2
                                   WHERE  whlr2.owner_name = v_FullCompany
                                   AND    trunc(whlr2.run_start_datetime) = trunc(SYSDATE)
                                   );
      
        EXCEPTION
        WHEN no_data_found THEN
          v_LoadRun     := NULL;
          v_CompanyStatus := 'RED';
          
          p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                    p_RunId,
                                                    'Load Run for '||v_FullCompany||' not started',
                                                    'ERROR',
                                                    'ERROR',
                                                    p_LogMethod);      
          
      END;
      
      -- If Load Run has started for this company then continue with checks
      IF v_LoadRun IS NOT NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Load Run for '||v_FullCompany||' started - Load Run Id:'||v_LoadRun,
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      
      
        -- Check to see if it has finished successfully
        IF v_status != 'COMPLETED' THEN
          -- Run hasn't yet completed - Check that no errors have occurred during run
          -- If Still running OK then keep status of GREEN as action would be to let
          -- it either finish or error
          
          BEGIN          
            SELECT COUNT(*)
            INTO   v_count
            FROM   wh_load_run_log_message whlr            
            WHERE  whlr.load_run_id = v_LoadRun
            AND    whlr.log_message LIKE '%ERROR%';
            
            EXCEPTION
            WHEN no_data_found THEN
              v_count := 0;
              
          END;
          
          -- Errors have occurred during run so mark as RED
          IF v_count > 0 THEN
            p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                      p_RunId,
                                                      'Load Run '||v_LoadRun||' has encountered errors',
                                                      'ERROR',
                                                      'ERROR',
                                                      p_LogMethod);      
            v_CompanyStatus := 'RED';            
          ELSE
            p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                      p_RunId,
                                                      'Load Run '||v_LoadRun||' still running - not encountered any errors',
                                                      'PROGRESS',
                                                      'INFO',
                                                      p_LogMethod);                
          END IF;
          
        ELSE
          -- Run has finished so check to see how many transactions have been loaded 
          BEGIN
            SELECT COUNT(*)
            INTO   v_Count
            FROM   datawr.r_booking_trans_history rbth
            WHERE  rbth.load_run_id = v_LoadRun
            AND    rbth.load_event = 'L';
            
            EXCEPTION
            WHEN no_data_found THEN
              v_Count := 0;
          END;
          
          IF v_Count < v_Companies.Min_Trans THEN
            -- Run has loaded less than minimum set level
            p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                      p_RunId,
                                                      'Load Run '||v_LoadRun||' has loaded less than minimum number of transaction',
                                                      'ERROR',
                                                      'ERROR',
                                                      p_LogMethod);      
            v_CompanyStatus := 'AMBER';            
          ELSE          
            -- Loaded enough transactions
            p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                      p_RunId,
                                                      'Load Run '||v_LoadRun||' has loaded more than minimum required transactions',
                                                      'PROGRESS',
                                                      'INFO',
                                                      p_LogMethod);                
          END IF;
        END IF;        
      END IF;

      -- Checks finished for company so log final outcome
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Checks for company '||v_companies.comp_key||' completed - Status of Company '||v_CompanyStatus,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);                


      -- Set Final Status for reporting
      IF v_FinalStatus != 'RED' THEN
        IF v_CompanyStatus != 'GREEN' THEN
          v_FinalStatus := v_CompanyStatus;
        END IF;  
      END IF;                
      
      -- Keep a list of failed companies
      IF v_CompanyStatus = 'RED' THEN
        v_FailedCompanies := v_FailedCompanies||v_companies.comp_key||' ';
      ELSIF v_CompanyStatus = 'AMBER' THEN
        v_TransCompanies := v_TransCompanies||v_companies.comp_key||' ';  
      END IF;
      
    END LOOP;
                   
    p_Status := v_FinalStatus;
    IF v_FinalStatus = 'GREEN' THEN
      -- Set return values
      p_Message := 'System Normal - All Companies Successfully Loaded';
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'System Normal - All Companies Successfully Loaded',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    ELSIF v_FinalStatus = 'AMBER' THEN
      p_Message := 'Tcat Integration has loaded less than expected transactions for following companies - '||v_TransCompanies;

      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'AMBER - Tcat Integration has loaded too few transactions',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      

      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Failed Companies '||v_TransCompanies,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    ELSE
      -- Set return values
      p_Message := 'Tcat Integration has failed for the following companies - '||v_FailedCompanies;
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'RED - Tcat Integration has failed',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      

      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Failed Companies '||v_FailedCompanies,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    END IF;                       
        
    -- Catch an exceptions that may have occurred
    EXCEPTION 
    WHEN Tcat_Exception THEN
      p_Status := 'RED';
      
    WHEN OTHERS THEN
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Error Occurred during App_Stat_TCat_Load '||SQLCODE||' '||SQLERRM,
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);
      p_ErrorCode := 1;

END App_Stat_TCat_Load;


-- ********************************************************************************
-- * Retail Profit Load Checking Routine                                          *
-- ********************************************************************************

PROCEDURE App_Stat_Retail_Profit (p_RunId     IN     application_log.run_id%TYPE,
                                  p_LogMethod IN     VARCHAR2,
                                  p_Status    IN OUT application_status.application_status_code%TYPE,
                                  p_Message   IN OUT application_status.application_message%TYPE,
                                  p_ErrorCode IN OUT VARCHAR2) IS 

  -- This procedure checks for the application status of Retail Profit
  -- It performs three simple checks to ascertain a successfull load
  -- 1. - Each company has a file for today
  -- 2. - Each Run has finished successfully
  -- 3. - If run has finished then count number of transactions loaded is greater than minimum level
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   14/03/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare relevant variables
  v_AppKey                application.application_key%TYPE := 'RET_PROF';
  v_CompanyList           application_registry.parameter_value%TYPE;
  v_MinTransList          application_registry.parameter_value%TYPE;  
  v_FinalStatus           application_status.application_status_code%TYPE := 'GREEN';
  v_Status                datawr.tc_control_run.status%TYPE;
  v_CompanyStatus         application_status.application_status_code%TYPE;
  v_Count                 INTEGER(10);

  v_RedFailedCompanies    VARCHAR2(100) := NULL;
  v_AmberFailedCompanies  VARCHAR2(100) := NULL;
        
  RetProf_Exception       EXCEPTION;


  -- Cursor to retrieve list of companies to check and the minimum number of
  -- transactions expected
  CURSOR Cur_Ret_Companies (c_CompanyList   IN  application_registry.parameter_value%TYPE,
                            c_MinTransList  IN  application_registry.parameter_value%TYPE) IS
  SELECT Companies.list_element comp_key,
         MinTrans.list_element min_trans
  FROM TABLE(p_common.Get_Separated_List(c_CompanyList)) Companies,
       TABLE(p_common.Get_Separated_List(c_MinTransList)) MinTrans
  WHERE Companies.list_element_position = MinTrans.list_element_position;
  
  BEGIN
    
    -- Set Returning paramters as success
    p_ErrorCode := 0;
    p_Status    := NULL;

    -- Get List of Companies and Minimum Transactions expected
    -- NB. The CSV Listing of the above data must in the same order for this to work
    v_CompanyList  := App_Util.Get_Parameter_Value(v_AppKey,'CompanyList');    
    v_MinTransList := App_Util.Get_Parameter_Value(v_AppKey,'MinTransList');
    
    IF v_CompanyList IS NULL THEN
      -- Can't get name of Check List file from Application_Registry
      -- Set as RED and investigate manually
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Unable to Find CompanyList file in app registry table',
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);      
      p_ErrorCode := 1;               
        
      RAISE RetProf_Exception;
    END IF;
    
    IF v_MinTransList IS NULL THEN
      -- Can't get name of Check List file from Application_Registry
      -- Set as RED and investigate manually
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Unable to Find MinTransList file in app registry table',
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);      
      p_ErrorCode := 1;               
        
      RAISE RetProf_Exception;
    END IF;
    
    FOR v_Companies IN Cur_Ret_Companies (v_CompanyList,
                                          v_MinTransList) LOOP

      -- Set Company Status to Green to start with
      v_CompanyStatus := 'GREEN';                                           
      
      -- Log which company being checked
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Checking Company '||v_Companies.Comp_Key,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);

      -- Check run for this company has started today
      BEGIN
        SELECT tcr.status,
               tcr.no_changed_bookings + tcr.no_new_bookings
        INTO   v_Status,
               v_count
        FROM   tc_control_run tcr
        WHERE  tcr.company_source_code = v_companies.comp_key
        AND    trunc(tcr.file_date)    = trunc(SYSDATE);
      
        EXCEPTION
        WHEN no_data_found THEN
          v_CompanyStatus := 'RED';
          v_Status := NULL;
          
          p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                    p_RunId,
                                                    'Load Run for '||v_companies.comp_key||' not started',
                                                    'ERROR',
                                                    'ERROR',
                                                    p_LogMethod);      
          
      END;
      
      -- If Load Run has started for this company then continue with checks
      IF v_Status IS NOT NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Load Run for '||v_companies.comp_key||' started',
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      
      
        -- Check to see if it has finished successfully
        IF v_status != 'COMPLETED' THEN
          -- Run hasn't yet completed
          
          -- Errors have occurred during run so mark as RED
          p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                    p_RunId,
                                                    'Load Run has not yet finished and may have encountered errors',
                                                    'ERROR',
                                                    'ERROR',
                                                    p_LogMethod);      
          v_CompanyStatus := 'RED';            
          
        ELSE
        
          -- Run has finished so check to see how many transactions have been loaded 
          IF v_Count < v_Companies.Min_Trans THEN
            -- Run has loaded less than minimum set level
            p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                      p_RunId,
                                                      'Load Run has loaded less than minimum number of transaction',
                                                      'ERROR',
                                                      'ERROR',
                                                      p_LogMethod);      
            v_CompanyStatus := 'AMBER';            
          ELSE          
            -- Loaded enough transactions
            p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                      p_RunId,
                                                      'Load Run has loaded more than minimum required transactions',
                                                      'PROGRESS',
                                                      'INFO',
                                                      p_LogMethod);                
          END IF;
        END IF;        
      END IF;

      -- Checks finished for company so log final outcome
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Checks for company '||v_companies.comp_key||' completed - Status of Company '||v_CompanyStatus,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);                


      -- Set Final Status for reporting
      IF v_FinalStatus != 'RED' THEN
        IF v_CompanyStatus != 'GREEN' THEN
          v_FinalStatus := v_CompanyStatus;          
        END IF;  
      END IF;                
      
      -- Keep a list of failed companies
      IF v_CompanyStatus = 'AMBER' THEN
        v_AmberFailedCompanies := v_AmberFailedCompanies||v_companies.comp_key||' ';        
      ELSIF v_CompanyStatus = 'RED' THEN
        v_RedFailedCompanies := v_RedFailedCompanies||v_companies.comp_key||' ';
      END IF;
      
    END LOOP;
                   
    p_Status := v_FinalStatus;
    
    IF v_FinalStatus = 'GREEN' THEN
      -- Set return values
      p_Message := 'System Normal - All Companies Successfully Loaded';
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'System Normal - All Companies Successfully Loaded',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    ELSIF v_FinalStatus = 'RED' THEN
      -- Set return values
      p_Message := 'Retail Profit has returned RED for the following companies - '||v_RedFailedCompanies;
      IF v_AmberFailedCompanies IS NOT NULL THEN
        p_message := p_message||'and AMBER for '||v_AmberFailedCompanies;
      END IF;
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'RED - Retail Profit has failed',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      

      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Failed Companies (RED) '||v_RedFailedCompanies,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
                                                
      IF v_AmberFailedCompanies IS NOT NULL THEN                                                
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Failed Companies (AMBER) '||v_AmberFailedCompanies,
                                                  'PROGRESS',
                                                  'INFO',
                                                  p_LogMethod);      
      END IF;                                              
    ELSIF v_FinalStatus = 'AMBER' THEN
      -- Set return values
      p_Message := 'Retail Profit has returned AMBER for the following companies - '||v_AmberFailedCompanies;
      
      -- and log message
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'AMBER - Retail Profit has failed',
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      

      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Amber Failed Companies '||v_AmberFailedCompanies,
                                                'PROGRESS',
                                                'INFO',
                                                p_LogMethod);      
    END IF;                       
        
    -- Catch an exceptions that may have occurred
    EXCEPTION 
    WHEN RetProf_Exception THEN
      p_Status := 'RED';
      
    WHEN OTHERS THEN
      p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                p_RunId,
                                                'Error Occurred during App_Stat_Retail_Profit '||SQLCODE||' '||SQLERRM,
                                                'ERROR',
                                                'ERROR',
                                                p_LogMethod);
      p_ErrorCode := 1;

END App_Stat_Retail_Profit;



-- ********************************************************************************
-- * Retail Profit Load Checking Routine                                          *
-- ********************************************************************************

PROCEDURE App_Stat_Retail_FX (p_RunId     IN     application_log.run_id%TYPE,
                              p_LogMethod IN     VARCHAR2,
                              p_Status    IN OUT application_status.application_status_code%TYPE,
                              p_Message   IN OUT application_status.application_message%TYPE,
                              p_ErrorCode IN OUT VARCHAR2) IS 


  -- This procedure checks for status of Retail FX Load
  -- It can only perform one check to ascertain whether Retail FX has loaded today
  -- and that is that there is at least one transaction with a business date of
  -- SYSDATE - 1
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   30/03/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  -- Declare relevant variables
  v_AppKey                application.application_key%TYPE := 'RETAILFX';
  
  v_Count                 INTEGER(10);
  
BEGIN

    -- Set Returning paramters as success
    p_ErrorCode := 0;
    p_Status    := NULL;

  -- Count number of transactions in fx_transaction table with a business_date 
  -- equal to sysdate - 1  
  SELECT COUNT(*) 
  INTO   v_count
  FROM   datawr.fx_transact fxt
  WHERE  trunc(fxt.business_date) = trunc(SYSDATE) - 1;
  
  IF v_count = 0 THEN
    -- Set return values
    p_Message := 'System Failure - 0 transactions Loaded for Retail FX';
      
    -- and log message
    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'Retail FX System Failure - 0 transactions loaded',
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
    -- and return status
    p_Status := 'RED';  
  ELSE
    -- Set return values
    p_Message := 'System Normal - '||v_count||' transactions Loaded';
      
    -- and log message
    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'System Normal - '||v_count||' transaction loaded',
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
    -- and return status
    p_Status := 'GREEN';  
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    p_ErrorCode := 1;
    p_Status    := 'RED';
    p_Message   := SQLCODE||' '||SQLERRM;
      
END App_Stat_Retail_FX;



-- ********************************************************************************
-- * TCC Load Checking Routine                                                    *
-- ********************************************************************************

PROCEDURE App_Stat_TccLoad (p_RunId     IN     application_log.run_id%TYPE,
                            p_LogMethod IN     VARCHAR2,
                            p_Status    IN OUT application_status.application_status_code%TYPE,
                            p_Message   IN OUT application_status.application_message%TYPE,
                            p_ErrorCode IN OUT VARCHAR2) IS

  -- This procedure checks for that the TCC Load has occurred for today
  -- If no run can be detected for today a warning Email will be sent    
  -- As long as the record exists in F_TCCLOAD_LOG then this procedure will
  -- return a GREEN status, if the log record shows a failure then this will
  -- be handled within the TCCLOAD shell script itself.
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   09/05/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  

  v_AppKey        application.application_key%TYPE;

  v_count         NUMBER(10);
  
BEGIN
  p_ErrorCode := 0;
  v_AppKey    := 'TCC_LOAD';
  
  BEGIN
    SELECT COUNT(*)
    INTO   v_count  
    FROM   dwr.f_tccload_log ftl
    WHERE  trunc(ftl.rundate) = trunc(SYSDATE);
    
    EXCEPTION
    WHEN no_data_found THEN
      v_count := 0;
  END;
  
  IF v_count = 0 THEN
    p_common.Debug_Message('Status Red'); 
    p_Status  := 'RED';
    p_Message := 'FX TCCLoad has not been run for today - Please investigate';

    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'FX TCCLoad has not run today',
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
  ELSE
    p_common.Debug_Message('Status Green'); 
    p_Status  := 'GREEN';
    p_Message := 'FX TCCLoad successfully loaded today';  

    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'FX TCCLoad has run today',
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
  END IF;
  
  EXCEPTION
  WHEN OTHERS THEN
    p_common.Debug_Message('Exception Stage'); 
    p_Status    := 'RED';
    p_ErrorCode := 1;
    p_Message   := 'Exception Raised during App_Stat_TccLoad '||SQLCODE;

    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'Exception Raised during App_Stat_TccLoad '||SQLCODE,
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
    
END App_Stat_TccLoad;



-- ********************************************************************************
-- * FX Order Checking Routine                                                    *
-- ********************************************************************************

PROCEDURE App_Stat_FXOrder (p_RunId     IN     application_log.run_id%TYPE,
                            p_LogMethod IN     VARCHAR2,
                            p_Status    IN OUT application_status.application_status_code%TYPE,
                            p_Message   IN OUT application_status.application_message%TYPE,
                            p_ErrorCode IN OUT VARCHAR2) IS

  -- This procedure checks that the FX Order load has occurred for today
  -- If no run can be detected for today a warning Email will be sent    
  -- As long as the record exists in F_ORDERS_LOG then this procedure will
  -- return a GREEN status, if the log record shows a failure then this will
  -- be handled within the FX Orders shell script itself.
  -- This procedure is called from the pacckage P_APPLICATION_STATUS_CHECK

  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   09/05/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  

  v_AppKey        application.application_key%TYPE;

  v_count         NUMBER(10);
  
BEGIN
  p_ErrorCode := 0;
  v_AppKey    := 'FXORDERS';
  
  BEGIN
    SELECT COUNT(*)
    INTO   v_count  
    FROM   dwr.f_order_log fol
    WHERE  trunc(fol.rundate) = trunc(SYSDATE);
    
    EXCEPTION
    WHEN no_data_found THEN
      v_count := 0;
  END;
  
  IF v_count = 0 THEN
    p_common.Debug_Message('Status Red'); 
    p_Status  := 'RED';
    p_Message := 'FX Orders has not been run for today - Please investigate';

    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'FX Orders has not run today',
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
  ELSE
    p_common.Debug_Message('Status Green'); 
    p_Status  := 'GREEN';
    p_Message := 'FX Orders successfully loaded today';  

    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'FX Orders has run today',
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
  END IF;
  
  EXCEPTION
  WHEN OTHERS THEN
    p_common.Debug_Message('Exception Stage'); 
    p_Status    := 'RED';
    p_ErrorCode := 1;
    p_Message   := 'Exception Raised during App_Stat_FXOrder '||SQLCODE;

    p_Application_Status_Check.App_Status_Log(v_AppKey,
                                              p_RunId,
                                              'Exception Raised during App_Stat_FXOrder '||SQLCODE,
                                              'PROGRESS',
                                              'INFO',
                                              p_LogMethod);      
    
END App_Stat_FXOrder;



-- ********************************************************************************
-- * DMIS Season Setting Routine - Not strictly Application Status                *
-- ********************************************************************************

PROCEDURE Set_Dmis_Season IS

  -- This procedure checks that the last season set in application_registry
  -- for DMIS checking is still the most prolific season (i.e. busiest in DMIS terms)
  -- The decision for this is that if the next season downloads more data over the
  -- seven previous days then the next season is set as the current season in the
  -- application registry table
  
  /*
  *****************************************************************************
  * Author          Date         Amendment                                    *
  *---------------------------------------------------------------------------*
  * John Durnford   13/10/2006   Original Version                             *
  *                                                                           *
  *****************************************************************************
  */  
  
  v_CurrentSeason        application_registry.parameter_value%TYPE;
  v_AppKey               application.application_key%TYPE := 'DMIS_PER';
  v_database             v$database.NAME%TYPE;
  
  v_NextSeason           VARCHAR2(3);
  
  v_TestDate             DATE;
  
  v_CurrentLoad          INTEGER(10);
  v_NextLoad             INTEGER(10);
  v_NextCount            INTEGER(10) := 0;
  v_DaysToCheck          INTEGER(10);
  
  Dmis_Error             EXCEPTION;

  -- Sub Function to Obtain the total number of bookings downloaded for the
  -- season and date passed in
  FUNCTION Get_Downloaded (p_Season  IN VARCHAR2,
                           p_Date    IN DATE) RETURN INTEGER IS

    v_Downloaded      INTEGER(10);
    
  BEGIN
    BEGIN
      SELECT MAX(mh.bookings_downloaded)
      INTO   v_downloaded
      FROM   monitor_history mh
      WHERE  mh.CONTEXT = 'DMIS'
      AND    trunc(mh.start_date) = trunc(p_Date)
      AND    mh.season_type = Upper(Substr(p_Season,1,1))
      AND    mh.season_year = To_Char(To_Date(Substr(p_Season,2,2),'rr'),'yyyy');
  
      IF v_downloaded IS NULL THEN
        v_Downloaded := 0;
      END IF;
      
      EXCEPTION 
      WHEN OTHERS THEN
        v_Downloaded := 0;
    END; 
    
    RETURN (v_Downloaded); 
  END Get_Downloaded;
      
BEGIN
  -- Get Current Season
  v_CurrentSeason := App_Util.Get_Parameter_Value(v_AppKey,'CurrentSeason');  
  
  -- Exit if unable to find
  IF v_CurrentSeason IS NULL THEN
    p_common.Debug_Message('Unable to Find CurrentSeason in application_registry table'); 
    RAISE Dmis_Error;
  END IF;  
  p_common.Debug_Message('Current Season '||v_CurrentSeason); 
  
  
  -- Get number of days to Check
  v_DaysToCheck := to_number(App_Util.Get_Parameter_Value(v_AppKey,'DaysToCheck'));  
  
  -- Exit if unable to find
  IF v_DaysToCheck IS NULL THEN
    p_common.Debug_Message('Unable to Find DaysToCheck in application_registry table'); 
    RAISE Dmis_Error;
  END IF;  
  p_common.Debug_Message('Days To Check '||v_DaysToCheck); 

  --  Work out what next season is
  BEGIN
  
    SELECT season_type||Substr(season_year,3,2)
    INTO   v_NextSeason
    FROM season ssn1
    WHERE ssn1.season_start_date = (SELECT (ssn2.season_end_date + 1)
                                    FROM   season ssn2
                                    WHERE  ssn2.season_type = Upper(Substr(v_CurrentSeason,1,1))
                                    AND    ssn2.season_year = To_Char(To_Date(Substr(v_CurrentSeason,2,2),'rr'),'yyyy')
                                   );
    
    p_common.Debug_Message('Next Season '||v_NextSeason); 
    
    -- Exit if unable to work it out
    EXCEPTION
    WHEN OTHERS THEN
      p_common.Debug_Message('Error Raised when trying to ascertain next season'); 
      p_common.debug_message(SQLERRM);
      RAISE Dmis_Error;
  END;

  -- Check number of days to see if next season has a higher load
  FOR v_Days IN 0..(v_DaysToCheck - 1) LOOP

    -- Set checking date
    v_TestDate := trunc(SYSDATE) - v_Days;
    
    p_common.Debug_Message('Test Date '||v_TestDate); 
    
    -- Get Total Bookings Downloaded by DMIS on day in question
    v_CurrentLoad := Get_Downloaded(v_CurrentSeason,v_TestDate);
    v_NextLoad    := Get_Downloaded(v_NextSeason,v_TestDate);
    
    p_common.Debug_Message('Current Load '||v_CurrentLoad); 
    p_common.Debug_Message('Next Load    '||v_NextLoad); 
    
    -- Increment Count if next season was busier than current season
    IF v_NextLoad > v_CurrentLoad THEN
      p_common.Debug_Message('Load in Next Season is greater than current season, increment count'); 
      v_NextCount := v_NextCount + 1;
      p_common.Debug_Message('Count currently on '||v_NextCount); 
    END IF;
        
  END LOOP;
  
  -- If every day was busier in next season then set next season as current season
  IF v_NextCount = v_DaysToCheck THEN
    p_common.Debug_Message('Last '||v_DaysToCheck||' days have had higher loads in next season'); 
    p_common.Debug_Message('Switching Seasons'); 
    
    BEGIN
      UPDATE application_registry ar
      SET    ar.parameter_value = v_NextSeason
      WHERE  ar.application_key = v_AppKey
      AND    ar.parameter_key   = 'CurrentSeason';
      
      COMMIT;
      
      p_common.Debug_Message('Season now set to '||v_NextSeason); 
      
      -- Email Dmis Users to inform them of change in season (based on red alerts)
      SELECT NAME 
      INTO v_database
      FROM v$database;
      
      p_Email_Role.Email_Role(v_AppKey||'_RED',
                              'DMIS Season has been changed on '||v_Database||' to '||v_NextSeason,
                              'DMIS Season has been changed on '||v_Database||' to '||v_NextSeason);
      
      EXCEPTION
      WHEN OTHERS THEN
        p_common.Debug_Message('Unable to Change Season in application_registry table'); 
        p_common.Debug_Message(SQLERRM); 
    END;
  END IF;
  
  EXCEPTION
  WHEN Dmis_Error THEN
    NULL;  
END Set_Dmis_Season;



BEGIN 
  -- Initialization
  NULL;
END p_App_Stat_Procedures;
/
