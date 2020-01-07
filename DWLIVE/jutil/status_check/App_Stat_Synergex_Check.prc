CREATE OR REPLACE PROCEDURE App_Stat_Synergex_Check (p_RunId     IN     application_log.run_id%TYPE,
                                                     p_LogMethod IN     VARCHAR2,
                                                     p_Status    IN OUT application_status.application_status_code%TYPE,
                                                     p_Message   IN OUT application_status.application_message%TYPE,
                                                     p_ErrorCode IN OUT VARCHAR2) IS 

  v_AppKey               application.application_key%TYPE := 'SYNERGEX';

  v_NumMinutes           INTEGER(10);
  v_AcceptedBkgs         INTEGER(10);
  v_WarningBkgs          INTEGER(10);
  v_count                INTEGER(10);
    
  Synergex_Exception         EXCEPTION;
  
  
  BEGIN
    
    p_ErrorCode := 0;
    p_Status    := NULL;
            
    BEGIN

      -- Get number of minutes to check load over
      v_NumMinutes := To_Number(App_Util.Get_Parameter_Value(v_AppKey,'NumMinutes'));
      IF v_NumMinutes IS NULL THEN
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Number of minutes not set in Application_Registry (NumMinutes)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Synergex_Exception;
      END IF;
      
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
        p_Application_Status_Check.App_Status_Log(v_AppKey,
                                                  p_RunId,
                                                  'Warning Booking level not set in Application_Registry (WarningBookings)',
                                                  'ERROR',
                                                  'ERROR',
                                                  p_LogMethod);
        p_ErrorCode := 1;               
        RAISE Synergex_Exception;
      END IF;

      SELECT
      COUNT(*)
      INTO v_count
      FROM dwrtc.booking_master bm
      WHERE bm.fch_load_timestamp >= SYSDATE - (1 / (24 * 60 / v_NumMinutes));
      
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
/
